`timescale 1ps / 1ps

module LOAD_extend(
		input [31:0] RAM_data,
		input [1:0] EXE_MEM_LOAD_type,
		input EXE_MEM_LOAD_sign,

		output reg [31:0] data_in
		);
		
	always @(*) 
	begin
		data_in = 0;
			casez({EXE_MEM_LOAD_type,EXE_MEM_LOAD_sign})
				3'b001: data_in = RAM_data;
				3'b101: data_in = {{16{RAM_data[15]}},RAM_data[15:0]};
				3'b011: data_in = {{24{RAM_data[7]}},RAM_data[7:0]};
				3'b100: data_in = {16'b0,RAM_data[15:0]};
				3'b010: data_in = {24'b0,RAM_data[7:0]};
				default: data_in = RAM_data;
			endcase
	end
endmodule