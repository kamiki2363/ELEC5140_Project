`timescale 1ps / 1ps

//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/04/22 10:39:50
// Design Name: 
// Module Name: branch_predict
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

module branch_predict(
		input clk,
		input rst,
		input CE,
		input [31:0] IF_instr,
		input [31:0] ID_instr,
		input [31:0] ID_PC,
		input zero,
		output wire [1:0] PC_mux_sel,
		output wire [1:0] branch_PC_mux1_sel,
		output wire [1:0] branch_PC_mux2_sel,
		output wire flush_signal
		);
		
		wire [1:0] PHT;

		
BHR_and_PHT table1
(
	.clk(clk),
	.rst(rst),
	.CE(CE),
	.ID_PC(ID_PC),
	.ID_opcode(ID_instr[6:0]),
	.ID_func3(ID_instr[14:12]),
	.zero_signal(zero),
	.PHT_out(PHT)
);

IF_MUX_sel sel1
(
	.clk(clk),
	.rst(rst),
	.CE(CE),
	.inst_in(IF_instr),
	.ID_opcode(ID_instr[6:0]),
	.ID_func3(ID_instr[14:12]),
	.PHT_in(PHT),
	.zero_signal(zero),
	.big_mux_sel(PC_mux_sel),
	.small_mux1_sel(branch_PC_mux1_sel),
	.small_mux2_sel(branch_PC_mux2_sel),
	.flush_signal(flush_signal)
);

endmodule