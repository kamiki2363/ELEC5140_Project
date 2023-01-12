`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/02/2021 03:44:28 PM
// Design Name: 
// Module Name: Reg1
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


module Reg1(
        output reg q,
        input d, 
        input clk,
        input rst
        );
        always @ (posedge clk or posedge rst) begin
        if(rst==1) begin
        q = 0;
        end
        else begin
        q<=d;
        end
        end
endmodule
