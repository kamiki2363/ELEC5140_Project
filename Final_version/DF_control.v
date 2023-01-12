`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/25/2021 10:10:22 PM
// Design Name: 
// Module Name: DF_control
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


module DF_control(
        input clk,
		input rst,
        input [4:0] IF_ID_written_reg,
        input [4:0] IF_ID_read_reg1,
        input [4:0] IF_ID_read_reg2,
        input [4:0] ID_EXE_written_reg,
        input [4:0] ID_EXE_read_reg1,
        input [4:0] ID_EXE_read_reg2,
        input [4:0] EXE_MEM_written_reg,
        input [4:0] EXE_MEM_read_reg1,
        input [4:0] EXE_MEM_read_reg2,
        input [1:0] ID_EXE_DatatoReg,
        input [1:0] IF_ID_DatatoReg,
        input [1:0] EXE_MEM_DatatoReg,
        input IF_ID_mem_w,
        input ID_EXE_mem_w,
        input EXE_MEM_mem_w,
                    

//        output reg load_data_in_to_data_out,

		output reg ALU_forwarding_on_A,
		output reg ALU_forwarding_on_B,
		output reg ALU_forwarding_on_data_out,
		output reg [1:0] ALU_data_forward_sel_A,
		output reg [1:0] ALU_data_forward_sel_B,
		output reg [1:0] ALU_data_forward_sel_data_out,
		output reg branch_forwarding_on_A,
		output reg branch_forwarding_on_B,
		output reg [1:0] branch_data_forward_sel_A,
		output reg [1:0] branch_data_forward_sel_B
         );
    wire read_wb_result;
    wire read_wb_result_B;
    wire read_wb_data_in_result;
    wire check_data_out_ID_MEM_out;
    wire check_data_out_ID_MEM_data_in_out;
    
    reg hazarddetect;
    reg hazarddetect_B;
    reg load_inst_dataforward;
    reg load_inst_dataforward_B;
    reg check_data_out_ID_MEM;
    reg check_data_out_ID_MEM_data_in;
	
	
	
	reg read_mem_result;
    reg read_wb_result_out;
    reg read_data_in_result_out;
    reg read_wb_data_in_result_out;
    reg branch_hazard_for_ALU_B_MEM_stage;
    reg branch_hazard_for_ALU_A_MEM_stage;
    reg read_mem_result_B;
    reg read_wb_result_out_B;
    reg read_wb_data_in_result_out_B;
    reg read_data_in_result_out_B;
    reg branch_hazard_for_ALU_B;
    reg branch_hazard_for_ALU_A;
    reg branch_hazard_for_ALU_A_ALU_out;
    reg branch_hazard_for_ALU_B_ALU_out;
    reg check_data_out_EXE_MEM;
    reg check_data_out_ID_MEM_out_1;
    reg check_data_out_EXE_MEM_data_in;
    reg check_data_out_ID_MEM_data_in_out_1;
	
	
	
	
        Reg1 _reg_read_wb_result_(
        .d(hazarddetect),
        .clk(clk),
		.rst(rst),
        .q(read_wb_result)
        );
        Reg1 _reg_read_data_in_result_(
        .d(load_inst_dataforward),
        .clk(clk),
		.rst(rst),
        .q(read_wb_data_in_result)
        );            
        Reg1 _reg_read_wb_result_B_(
        .d(hazarddetect_B),
        .clk(clk),
		.rst(rst),
        .q(read_wb_result_B)
        );
        Reg1 _reg_read_data_in_result_B_(
        .d(load_inst_dataforward_B),
        .clk(clk),
		.rst(rst),
        .q(read_wb_data_in_result_B)
        );     
        Reg1 _reg_check_alu_data_out_(
        .d(check_data_out_ID_MEM),
        .clk(clk),
		.rst(rst),
        .q(check_data_out_ID_MEM_out)
        );   
        Reg1 _reg_check_alu_data_out_data_in_(
        .d(check_data_out_ID_MEM_data_in),
        .clk(clk),
		.rst(rst),
        .q(check_data_out_ID_MEM_data_in_out)
        );   



    always @ (*) begin
    branch_hazard_for_ALU_A_ALU_out =0;
    branch_hazard_for_ALU_B_ALU_out =0;
    branch_hazard_for_ALU_A = 0;
    branch_hazard_for_ALU_B = 0;
    branch_hazard_for_ALU_A_MEM_stage =0;
    read_mem_result = 0;  
    read_mem_result_B = 0;
    hazarddetect_B =0;
    load_inst_dataforward_B =0;
    read_data_in_result_out_B = 0;
    check_data_out_EXE_MEM = 0;
    check_data_out_ID_MEM  = 0; 
    check_data_out_EXE_MEM_data_in = 0;
    check_data_out_ID_MEM_data_in  = 0; 
    read_data_in_result_out = 0;
//    load_data_in_to_data_out = 0;
    branch_hazard_for_ALU_B_MEM_stage =0;
    read_wb_result_out = read_wb_result;
    read_wb_result_out_B = read_wb_result_B;
    read_wb_data_in_result_out = read_wb_data_in_result;
    read_wb_data_in_result_out_B = read_wb_data_in_result_B;
    check_data_out_ID_MEM_data_in_out_1 = check_data_out_ID_MEM_data_in_out;
    check_data_out_ID_MEM_out_1  = check_data_out_ID_MEM_out;
    hazarddetect =0; 
    load_inst_dataforward =0;

        
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg1 && EXE_MEM_DatatoReg == 2'b00 ) begin //reading the hazard from  ID and EXE
            read_mem_result = 1; 
        end

        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 && EXE_MEM_DatatoReg == 2'b00) begin//reading the hazard from  IF and EXE
             hazarddetect = 1;
             branch_hazard_for_ALU_A_ALU_out  =1;
        end

        if (EXE_MEM_written_reg != 0 && (EXE_MEM_written_reg == ID_EXE_read_reg1 && EXE_MEM_DatatoReg == 2'b01 )) begin//reading the load  hazard from  IF and EXE
            read_data_in_result_out = 1; 
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1  && EXE_MEM_DatatoReg == 2'b01) begin
             load_inst_dataforward = 1;
        end
//        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg2  &&  (EXE_MEM_DatatoReg == 2'b01 && ID_EXE_mem_w == 1)) begin
//             load_data_in_to_data_out = 1;
//        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg2  &&  ID_EXE_mem_w == 1 && EXE_MEM_DatatoReg == 2'b00) begin
             check_data_out_EXE_MEM = 1;
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2  &&  IF_ID_mem_w == 1 && EXE_MEM_DatatoReg == 2'b00) begin
             check_data_out_ID_MEM = 1;
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg2  && EXE_MEM_DatatoReg == 2'b01 && ID_EXE_mem_w == 1) begin
             check_data_out_EXE_MEM_data_in = 1;
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2  &&  EXE_MEM_DatatoReg == 2'b01 && IF_ID_mem_w == 1) begin
             check_data_out_ID_MEM_data_in = 1;
        end

        
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == ID_EXE_read_reg2 && ID_EXE_mem_w == 0 && EXE_MEM_DatatoReg == 2'b00) begin //reading the hazard from  ID and EXE
            read_mem_result_B = 1; 
        end

        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 && IF_ID_mem_w == 0 && EXE_MEM_DatatoReg == 2'b00) begin//reading the hazard from  IF and EXE
             hazarddetect_B = 1;
             branch_hazard_for_ALU_B_ALU_out  =1;
        end

        if (EXE_MEM_written_reg != 0 && ID_EXE_read_reg2 != 0  && EXE_MEM_written_reg == ID_EXE_read_reg2 && EXE_MEM_DatatoReg == 2'b01 && ID_EXE_mem_w == 0) begin//reading the load  hazard from  IF and EXE
            read_data_in_result_out_B = 1; 
        end
        if (EXE_MEM_written_reg != 0 && IF_ID_read_reg2 != 0  && EXE_MEM_written_reg == IF_ID_read_reg2  && EXE_MEM_DatatoReg == 2'b01 && IF_ID_mem_w == 0 ) begin
             load_inst_dataforward_B = 1;
        end
        // for the barnch predictor 
        if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg2 && EXE_MEM_DatatoReg == 2'b00) begin //
            branch_hazard_for_ALU_B = 1; 
        end
     
        if (ID_EXE_written_reg != 0 && ID_EXE_written_reg == IF_ID_read_reg1 && EXE_MEM_DatatoReg == 2'b00) begin //
            branch_hazard_for_ALU_A = 1; 
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2  && EXE_MEM_DatatoReg == 2'b00) begin
             check_data_out_ID_MEM = 1;
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg1 &&  EXE_MEM_DatatoReg == 2'b01 ) begin//reading the hazard from  IF and EXE
                     branch_hazard_for_ALU_A_MEM_stage  =1;
        end
        if (EXE_MEM_written_reg != 0 && EXE_MEM_written_reg == IF_ID_read_reg2 &&  EXE_MEM_DatatoReg == 2'b01) begin
             branch_hazard_for_ALU_B_MEM_stage  =1;
        end
   
  

  
        casez({read_wb_data_in_result_out,read_wb_result_out,read_data_in_result_out,read_mem_result})
		{1'b?,1'b?,1'b?,1'b1}:
		begin
			ALU_data_forward_sel_A = 2'b00;
			ALU_forwarding_on_A = 1'b1;
		end
		{1'b?,1'b?,1'b1,1'b?}:
		begin
			ALU_data_forward_sel_A = 2'b01;
			ALU_forwarding_on_A = 1'b1;
		end
		{1'b?,1'b1,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_A = 2'b10;
			ALU_forwarding_on_A = 1'b1;
		end
		{1'b1,1'b?,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_A = 2'b11;
			ALU_forwarding_on_A = 1'b1;
		end
		default:
		begin
			ALU_data_forward_sel_A = 2'b00;
			ALU_forwarding_on_A = 1'b0;
		end
		endcase
		
		
		casez({read_wb_data_in_result_out_B,read_wb_result_out_B,read_data_in_result_out_B,read_mem_result_B})
		{1'b?,1'b?,1'b?,1'b1}:
		begin
			ALU_data_forward_sel_B = 2'b00;
			ALU_forwarding_on_B = 1'b1;
		end
		{1'b?,1'b?,1'b1,1'b?}:
		begin
			ALU_data_forward_sel_B = 2'b01;
			ALU_forwarding_on_B = 1'b1;
		end
		{1'b?,1'b1,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_B = 2'b10;
			ALU_forwarding_on_B = 1'b1;
		end
		{1'b1,1'b?,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_B = 2'b11;
			ALU_forwarding_on_B = 1'b1;
		end
		default:
		begin
			ALU_data_forward_sel_B = 2'b00;
			ALU_forwarding_on_B = 1'b0;
		end
		endcase
		
		
		
		casez({branch_hazard_for_ALU_A_MEM_stage,branch_hazard_for_ALU_A,branch_hazard_for_ALU_A_ALU_out})
		{1'b?,1'b?,1'b1}:
		begin
			branch_data_forward_sel_A = 2'b00;
			branch_forwarding_on_A = 1'b1;
		end
		{1'b?,1'b1,1'b?}:
		begin
			branch_data_forward_sel_A = 2'b01;
			branch_forwarding_on_A = 1'b1;
		end
		{1'b1,1'b?,1'b?}:
		begin
			branch_data_forward_sel_A = 2'b10;
			branch_forwarding_on_A = 1'b1;
		end
		default:
		begin
			branch_data_forward_sel_A = 2'b00;
			branch_forwarding_on_A = 1'b0;
		end
		endcase
		
		casez({branch_hazard_for_ALU_B_MEM_stage,branch_hazard_for_ALU_B,branch_hazard_for_ALU_B_ALU_out})
		{1'b?,1'b?,1'b1}:
		begin
			branch_data_forward_sel_B = 2'b00;
			branch_forwarding_on_B = 1'b1;
		end
		{1'b?,1'b1,1'b?}:
		begin
			branch_data_forward_sel_B = 2'b01;
			branch_forwarding_on_B = 1'b1;
		end
		{1'b1,1'b?,1'b?}:
		begin
			branch_data_forward_sel_B = 2'b10;
			branch_forwarding_on_B = 1'b1;
		end
		default:
		begin
			branch_data_forward_sel_B = 2'b00;
			branch_forwarding_on_B = 1'b0;
		end
		endcase

    casez({check_data_out_ID_MEM_data_in_out_1,check_data_out_ID_MEM_out_1, check_data_out_EXE_MEM_data_in ,check_data_out_EXE_MEM})
		{1'b?,1'b?,1'b?,1'b1}:
		begin
			ALU_data_forward_sel_data_out = 2'b00;
			ALU_forwarding_on_data_out = 1'b1;
		end
		{1'b?,1'b?,1'b1,1'b?}:
		begin
			ALU_data_forward_sel_data_out = 2'b01;
			ALU_forwarding_on_data_out = 1'b1;
		end
		{1'b?,1'b1,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_data_out = 2'b10;
			ALU_forwarding_on_data_out = 1'b1;
		end
		{1'b1,1'b?,1'b?,1'b?}:
		begin
			ALU_data_forward_sel_data_out = 2'b11;
			ALU_forwarding_on_data_out = 1'b1;
		end
		default:
		begin
			ALU_data_forward_sel_data_out = 2'b00;
			ALU_forwarding_on_data_out = 1'b0;
		end
		endcase
		
    end   
endmodule
