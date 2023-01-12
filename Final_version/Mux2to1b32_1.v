`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2021 10:50:25 PM
// Design Name: 
// Module Name: Mux2to1b32_1
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
module Mux2to1b32_1(
		input s,
		input [31:0] I0,
		input [31:0] I1,
		output reg [31:0] o
    );
    always @(*) begin
    	case(s)
			1'b0: o = I0;
			1'b1: o = I1;
			default: o = I0;
		endcase

    end
endmodule
