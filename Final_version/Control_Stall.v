`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/12 08:45:29
// Design Name: 
// Module Name: Control_Stall
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


module Control_Stall(
        input flush_signal,
        output reg IF_ID_cstall
    );
    always @ (*) begin
        IF_ID_cstall = 1'b0;
        if (flush_signal) begin
            IF_ID_cstall = 1'b1;
        end
    end
endmodule
