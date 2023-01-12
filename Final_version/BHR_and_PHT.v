`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/03 22:21:50
// Design Name: 
// Module Name: BHR_and_PHT
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

//negedge for component inside the stage, posedge for register between the stage!!!

module BHR_and_PHT(
		input clk,
		input rst,
		input CE,
		input [31:0] ID_PC,				
		input [6:0] ID_opcode,
		input [2:0] ID_func3,
		input zero_signal,
		output wire [1:0] PHT_out
		);
		
		reg [6:0] IF_opcode;
		reg [3:0] BHR_stored;
		reg [1:0] PHT;
		reg [6:0] PHT_address;
		reg [1:0] PHT_stored [0:127];
		assign PHT_out = PHT;
		
		
		integer i;
		
		initial begin
			for (i=0;i<127;i=i+1) begin
				PHT_stored[i] = 2'b10;
			end
		end
			

			
		//Store current BHR
		always @(posedge clk or posedge rst) begin
		if (rst == 1) begin					// reset
			BHR_stored <= 0;
		end
		else begin
			if (ID_opcode == 7'b1100011) //&& !SD_PC_dstall && !SD_B_L_dstall) 
			begin
				case (result_upadte(ID_opcode, ID_func3, zero_signal))
				2'b00: BHR_stored <= {BHR_stored[2:0],1'b1};
				2'b01: BHR_stored <= {BHR_stored[2:0],1'b0};
				2'b10: BHR_stored <= {BHR_stored[2:0],1'b1};
				2'b11: BHR_stored <= {BHR_stored[2:0],1'b0};
				default: BHR_stored <= BHR_stored;
				endcase
			end
		end	
		end
		
		always @ (*)
		begin
			PHT_address = {ID_PC[4:2], BHR_stored};
		end
		
		always @(negedge clk or posedge rst) begin
		if (rst == 1) begin					// reset
			PHT <= 2'b10;
		end
		else 
			begin
				PHT <= PHT_stored[PHT_address];
			end
		end
		
		always @(posedge clk) 
		begin
			if (ID_opcode == 7'b1100011)
				begin
					case (result_upadte(ID_opcode, ID_func3, zero_signal))
							2'b00: 
								begin							//BEQ taken (actual)
									if (PHT!=3) 
										begin				
											PHT_stored[PHT_address] <= PHT+1;
										end
									else 
										begin	
											PHT_stored[PHT_address] <= PHT;
										end
								end
							2'b01: 
								begin							//BEQ not taken (actual)
									if (PHT!=0) 
										begin				
											PHT_stored[PHT_address] <= PHT-1;
										end
									else 
										begin	
											PHT_stored[PHT_address] <= PHT;
										end
								end
							2'b10: 
								begin							//BNE taken (actual)
									if (PHT!=3) 
										begin				
											PHT_stored[PHT_address] <= PHT+1;
										end
									else 
										begin	
											PHT_stored[PHT_address] <= PHT;
										end
								end
							2'b11: 
								begin							//BNE not taken (actual)
									if (PHT!=0) 
										begin				
											PHT_stored[PHT_address] <= PHT-1;
										end
									else 
										begin	
											PHT_stored[PHT_address] <= PHT;
										end
								end	
							default: PHT_stored[PHT_address] <= PHT_stored[PHT_address];
					endcase
				end
		end

		function integer result_upadte;
		input [6:0] old_opcode;
		input [2:0] old_func3;
		input zero;
			reg [1:0] case_sel;
			begin
				casez ({old_opcode, old_func3, zero})
				{7'b1100011, 3'b000, 1'b1}: case_sel = 2'b00;						//BEQ taken (actual)
				{7'b1100011, 3'b000, 1'b0}: case_sel = 2'b01;						//BEQ not taken (actual)
				{7'b1100011, 3'b001, 1'b0}: case_sel = 2'b10;						//BNE taken (actual)
				{7'b1100011, 3'b001, 1'b1}: case_sel = 2'b11;						//BNE not taken (actual)	
				{7'b1100011, 3'b1??, 1'b1}: case_sel = 2'b00;						//BLT/BGE/BLTU/BGEU taken (actual)
				{7'b1100011, 3'b1??, 1'b0}: case_sel = 2'b01;						//BLT/BGE/BLTU/BGEU not taken (actual)
				default: case_sel = 2'b00;											
				endcase	
			result_upadte = case_sel;
			end
		endfunction
		
		
endmodule	