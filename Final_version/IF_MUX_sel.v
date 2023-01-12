`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/03 22:21:50
// Design Name: 
// Module Name: IF_MUX_sel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module IF_MUX_sel(
		input clk,
		input rst,
		input CE,
		input [31:0] inst_in,
		input [6:0] ID_opcode,
		input [2:0] ID_func3,
		input [1:0] PHT_in,
		input zero_signal,
		output wire [1:0] big_mux_sel,
		output wire [1:0] small_mux1_sel,
		output wire [1:0] small_mux2_sel,
		output wire flush_signal
		);
		
		reg [6:0] IF_opcode;
		reg [1:0] temp_big_mux_sel;
		reg [1:0] temp_small_mux1_sel;
		reg [1:0] temp_small_mux2_sel;
		reg temp_flush_signal;
		
		reg [6:0] SD_IF_opcode;
		reg [6:0] SD_ID_opcode;
		reg [2:0] SD_ID_func3;
		
		assign big_mux_sel = temp_big_mux_sel;
		assign small_mux1_sel = temp_small_mux1_sel;
		assign small_mux2_sel = temp_small_mux2_sel;
		assign flush_signal = temp_flush_signal;
		
		initial begin
			temp_big_mux_sel = 2'b00;
			temp_small_mux1_sel = 2'b00;
			temp_small_mux2_sel = 2'b00;
			temp_flush_signal = 1'b0;
		end
		
		always @ (*) 
		begin
		IF_opcode = inst_in[6:0];
			if (SD_ID_opcode == 7'b1100011) 
			begin		
				temp_flush_signal = ~(check_pre (SD_ID_opcode, SD_ID_func3, zero_signal, PHT_in));				//check prediction is correct or not
				if (temp_flush_signal) 
				begin																//do recovery if prediction is not correct
					temp_big_mux_sel = 2'b01;
					case (final_sel (SD_ID_opcode, SD_ID_func3, zero_signal, PHT_in))
						2'b00: 
						begin							//not execute
							temp_small_mux1_sel = 0;
							temp_small_mux2_sel = 0;
						end
						2'b01: 
						begin							//not execute
							temp_small_mux1_sel = 0;
							temp_small_mux2_sel = 1;
						end
						2'b10: 
						begin							//predict taken, actual not taken, wrong prediction
							temp_small_mux1_sel = 1;
							temp_small_mux2_sel = 1;
						end
						2'b11: 
						begin							//predict not taken, actual taken, wrong prediction, PS: test needed
							temp_small_mux1_sel = 1;
							temp_small_mux2_sel = 2;
						end
						default: 
						begin
							temp_small_mux1_sel = 3;	//not used
							temp_small_mux2_sel = 3;	//not used
						end
					endcase
				end
				else if (!temp_flush_signal) //need to double check
				begin
					if (SD_IF_opcode != 7'b1100011)
					begin
						//if prediction is correct, normal operation
						//Note: even IF stage is jump instr, still PC+4, will correct in next clk cycle
						temp_big_mux_sel = 2'b00;
					end
					else if (SD_IF_opcode == 7'b1100011) 
					begin
						temp_big_mux_sel = 2'b01;											//branch & predict
						case (pre_sel(SD_IF_opcode, PHT_in))
							2'b00:
							begin												//predict taken
								temp_small_mux1_sel = 0;
								temp_small_mux2_sel = 0;
							end
							2'b01:
							begin												//predict not taken
								temp_small_mux1_sel = 0;
								temp_small_mux2_sel = 1;
							end
							default:
							begin
								temp_small_mux1_sel = 3;						//not used
								temp_small_mux2_sel = 3;						//not used
							end
						endcase
					end
				end
			end
			//for JAL and JALR
			else if ((SD_ID_opcode == 7'b1101111) || (SD_ID_opcode == 7'b1100111)) 
			begin
				temp_flush_signal = 0;
				case (SD_ID_opcode)											//when opcode is not branch
					7'b1101111: temp_big_mux_sel = 2'b10;						//JAL, add_jal_out+4
					7'b1100111: temp_big_mux_sel = 2'b11;						//JALR, add_jalr_out+4 
					default: temp_big_mux_sel = 2'b00;							//should not execute
				endcase
			end
			else if (SD_IF_opcode == 7'b1100011) 
			begin
				temp_flush_signal = 0;
				temp_big_mux_sel = 2'b01;										//branch & predict
				case (pre_sel(SD_IF_opcode, PHT_in))
					2'b00: begin												//predict taken
						temp_small_mux1_sel = 0;
						temp_small_mux2_sel = 0;
						end
					2'b01: begin												//predict not taken
						temp_small_mux1_sel = 0;
						temp_small_mux2_sel = 1;
						end
					default: begin
						temp_small_mux1_sel = 3;								//not used
						temp_small_mux2_sel = 3;								//not used
						end
				endcase
			end
			else begin
				temp_flush_signal = 0;
				//Note: even IF stage is jump instr, still PC+4, will correct in next clk cycle
				temp_big_mux_sel = 2'b00;
			end
		end
		
		always @(negedge clk or posedge rst) 
		begin
			if (rst == 1) begin					// reset
				SD_IF_opcode <= 0;
				SD_ID_opcode <= 0;
				SD_ID_func3 <= 0;
			end
		else
			begin
				SD_IF_opcode <= IF_opcode;
				SD_ID_opcode <= ID_opcode;
				SD_ID_func3 <= ID_func3;
			end	
		end
		
		function integer pre_sel;
		input [6:0] opcode;
		input [1:0] PHT;
			reg [1:0] sel_predict;
			begin
				casez ({opcode, PHT})
				{7'b1100011, 2'b1?}: sel_predict = 2'b00;						//predict taken
				{7'b1100011, 2'b0?}: sel_predict = 2'b01;						//predict not taken
				default: sel_predict = 2'b00;											
				endcase	
			pre_sel = sel_predict;
			end
		endfunction
		
		function reg check_pre;
		input [6:0] old_opcode;
		input [2:0] old_func3;
		input zero;
		input [1:0] PHT;
			reg correct;
			begin
				casez ({old_opcode, old_func3, zero, PHT})
				{7'b1100011, 3'b000, 1'b1, 2'b1?}: correct = 1'b1;						//BEQ, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b000, 1'b0, 2'b0?}: correct = 1'b1;						//BEQ, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b000, 1'b0, 2'b1?}: correct = 1'b0;						//BEQ, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b000, 1'b1, 2'b0?}: correct = 1'b0;						//BEQ, predict not taken, actual taken, wrong prediction
				{7'b1100011, 3'b001, 1'b0, 2'b1?}: correct = 1'b1;						//BNE, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b001, 1'b1, 2'b0?}: correct = 1'b1;						//BNE, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b001, 1'b1, 2'b1?}: correct = 1'b0;						//BNE, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b001, 1'b0, 2'b0?}: correct = 1'b0;						//BNE, predict not taken, actual taken, wrong prediction
				{7'b1100011, 3'b1??, 1'b1, 2'b1?}: correct = 1'b1;						//BLT/BGE/BLTU/BGEU, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b1??, 1'b0, 2'b0?}: correct = 1'b1;						//BLT/BGE/BLTU/BGEU, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b1??, 1'b0, 2'b1?}: correct = 1'b0;						//BLT/BGE/BLTU/BGEU, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b1??, 1'b1, 2'b0?}: correct = 1'b0;						//BLT/BGE/BLTU/BGEU, predict not taken, actual taken, wrong prediction
				default: correct = 1'b1;											
				endcase	
			check_pre = correct;
			end
		endfunction
		
		function integer final_sel;
		input [6:0] old_opcode;
		input [2:0] old_func3;
		input zero;
		input [1:0] PHT;
			reg [1:0] sel_correction;
			begin
				casez ({old_opcode, old_func3, zero, PHT})
				{7'b1100011, 3'b000, 1'b1, 2'b1?}: sel_correction = 2'b00;						//BEQ, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b000, 1'b0, 2'b0?}: sel_correction = 2'b01;						//BEQ, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b000, 1'b0, 2'b1?}: sel_correction = 2'b10;						//BEQ, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b000, 1'b1, 2'b0?}: sel_correction = 2'b11;						//BEQ, predict not taken, actual taken, wrong prediction
				{7'b1100011, 3'b001, 1'b0, 2'b1?}: sel_correction = 2'b00;						//BNE, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b001, 1'b1, 2'b0?}: sel_correction = 2'b01;						//BNE, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b001, 1'b1, 2'b1?}: sel_correction = 2'b10;						//BNE, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b001, 1'b0, 2'b0?}: sel_correction = 2'b11;						//BNE, predict not taken, actual taken, wrong prediction
				{7'b1100011, 3'b1??, 1'b1, 2'b1?}: sel_correction = 2'b00;						//BLT/BGE/BLTU/BGEU, predict taken, actual taken, correct prediction
				{7'b1100011, 3'b1??, 1'b0, 2'b0?}: sel_correction = 2'b01;						//BLT/BGE/BLTU/BGEU, predict not taken, actual not taken, correct prediction
				{7'b1100011, 3'b1??, 1'b0, 2'b1?}: sel_correction = 2'b10;						//BLT/BGE/BLTU/BGEU, predict taken, actual not taken, wrong prediction
				{7'b1100011, 3'b1??, 1'b1, 2'b0?}: sel_correction = 2'b11;						//BLT/BGE/BLTU/BGEU, predict not taken, actual taken, wrong prediction
				default: sel_correction = 2'b00;											
				endcase
			final_sel = sel_correction;
			end
		endfunction
		
endmodule		