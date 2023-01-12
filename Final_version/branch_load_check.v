`timescale 1ps / 1ps

module branch_load_check(
		input [31:0] inst_in,
		input [31:0] IF_ID_inst_in,
		
        output reg branch_load_dstall
    );
	
	always @(*)
	begin
		branch_load_dstall = 1'b0;
		
		if ((inst_in[6:0] == 7'b1100011) && (IF_ID_inst_in[6:0] == 7'b0000011) )
		begin
			if ((inst_in[19:15] == IF_ID_inst_in[11:7]) || (inst_in[24:20] == IF_ID_inst_in[11:7]))
			begin
				branch_load_dstall = 1'b1;
			end				
		end
	end
	
endmodule