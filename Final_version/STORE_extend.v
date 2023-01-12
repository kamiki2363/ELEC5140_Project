`timescale 1ps / 1ps

module STORE_extend(
		input [31:0] ID_EXE_Data_out_2,
		input [1:0] ID_EXE_STORE_type,

		output reg [31:0] ID_EXE_Data_extended
		);
		
	always @(*) 
	begin
		ID_EXE_Data_extended = 0;
			case(ID_EXE_STORE_type)
				2'b00: ID_EXE_Data_extended = ID_EXE_Data_out_2;
				2'b10: ID_EXE_Data_extended = {{16{ID_EXE_Data_out_2[15]}},ID_EXE_Data_out_2[15:0]};
				2'b01: ID_EXE_Data_extended = {{24{ID_EXE_Data_out_2[7]}},ID_EXE_Data_out_2[7:0]};
				default: ID_EXE_Data_extended = ID_EXE_Data_out_2;
			endcase
	end
endmodule