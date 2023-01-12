`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2021/03/10 19:39:55
// Design Name: 
// Module Name: RV32iPCPU
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


module RV32iPCPU(
    input clk,
    input rst,
    input [31:0] RAM_data_in,   // MEM
    input [31:0] inst_in,   // IF, from PC_out
    
    output [31:0] ALU_out,  // From MEM, address out, for fetching RAM_data_in
    output [31:0] data_out, // From MEM, to be written into data memory
    output mem_w,           // From MEM, write valid, for store instructions
    output [31:0] PC_out    // From IF
    );
    wire V5;
    wire N0;
	wire [31:0] PC;
    wire [31:0] Imm_32;
    wire [31:0] add_branch_out;
    wire [31:0] add_jal_out;
    wire [31:0] add_jalr_out;

    wire [4:0] Wt_addr;
    wire [31:0] Wt_data;
//    wire [31:0] Wt_data_1;//for data forward from ALU out 
    wire [31:0] rdata_A;
    wire [31:0] rdata_B;
    wire [31:0] PC_wb;
    wire [31:0] ALU_A;
    wire [31:0] ALU_B;
    assign V5 = 1'b1;
    assign N0 = 1'b0;
    
    
    wire zero;              // ID
    wire [1:0] PC_jump_sel; // ID
    wire ALUSrc_A;          // EXE
    wire [1:0] ALUSrc_B;    // EXE
    wire [4:0] ALU_Control; // EXE
    wire RegWrite;          // WB
    wire [1:0] DatatoReg;   // WB
    
	wire [1:0] LOAD_type;
	wire LOAD_sign;
	wire [1:0] STORE_type;
	
	wire [31:0] data_in;
//    wire RegDst; // WB
//    wire Jal; // WB
    
    // IF_ID
    wire [31:0] IF_ID_inst_in;
    wire [31:0] IF_ID_PC;
    wire [31:0] IF_ID_Data_out;
    wire IF_ID_mem_w;
    wire [4:0] IF_ID_written_reg;
    wire [4:0] IF_ID_read_reg1;
    wire [4:0] IF_ID_read_reg2;
    
    //ID
    wire [31:0] Branch_data_ALU_A_1;
    wire [31:0] Branch_data_ALU_B_1;
    wire [31:0] Branch_data_ALU_A_2;
    wire [31:0] Branch_data_ALU_B_2;
    
    // ID_EXE
    wire [31:0] ID_EXE_inst_in;
    wire [31:0] ID_EXE_PC;
    wire [31:0] ID_EXE_ALU_A;
    wire [31:0] ID_EXE_ALU_B;
    wire [4:0] ID_EXE_ALU_Control;
    wire [31:0] ID_EXE_Data_out;
    wire ID_EXE_mem_w;
    wire [1:0] ID_EXE_DatatoReg;
    wire ID_EXE_RegWrite;
	
	wire [1:0] ID_EXE_LOAD_type;
	wire [1:0] ID_EXE_STORE_type;
    wire ID_EXE_LOAD_sign;
	
    wire [4:0] ID_EXE_written_reg;
    wire [4:0] ID_EXE_read_reg1;
    wire [4:0] ID_EXE_read_reg2;
    
    wire [31:0] ID_EXE_ALU_out;
	
	wire [31:0] ID_EXE_Data_extended;

    // EXE
    wire [31:0] _alu_Source_A_1_ALU_A;
    wire [31:0] _alu_Source_A_2_ALU_A;
    wire [31:0] _alu_Source_B_1_ALU_B;
    wire [31:0] _alu_Source_B_2_ALU_B;
    wire [31:0] ID_EXE_Data_out_1;
    wire [31:0] ID_EXE_Data_out_2;
	wire [31:0] _data_out_Source;
	wire [31:0] _data_out_Source_1;
	
    // EXE_MEM
    wire [31:0] EXE_MEM_inst_in;
    wire [31:0] EXE_MEM_PC;
    wire [31:0] EXE_MEM_ALU_out;
    wire [31:0] EXE_MEM_Data_out;
    wire [31:0]EXE_MEM_Data_out_1;
    wire EXE_MEM_mem_w;
    wire [1:0] EXE_MEM_DatatoReg;
    wire EXE_MEM_RegWrite;

	wire [1:0] EXE_MEM_LOAD_type;
    wire EXE_MEM_LOAD_sign;
	
    wire [4:0] EXE_MEM_written_reg;
    wire [4:0] EXE_MEM_read_reg1;
    wire [4:0] EXE_MEM_read_reg2;
    
    // MEM_WB
    wire [31:0] MEM_WB_inst_in;
    wire [31:0] MEM_WB_PC;
    wire [31:0] MEM_WB_ALU_out;
    wire [31:0] MEM_WB_Data_in;
    wire [1:0] MEM_WB_DatatoReg;
    wire MEM_WB_RegWrite;
   
   // Stall
   wire IF_ID_cstall;

   
   //new signal
   wire flush;
   wire branch_load_dstall;
   wire [31:0] Imm_IF;
   wire [1:0] IF_B_MUX1_sel;
   wire [1:0] IF_B_MUX2_sel;
   wire [31:0] B_sel1_data;
   wire [31:0] B_sel2_data;
   wire [1:0] MUX5_sel;
   
   wire ALU_forwarding_on_A;
   wire ALU_forwarding_on_B;
   wire ALU_forwarding_on_data_out;
   wire [1:0] ALU_data_forward_sel_A;
   wire [1:0] ALU_data_forward_sel_B;
   wire [1:0] ALU_data_forward_sel_data_out;
   wire branch_forwarding_on_A;
   wire branch_forwarding_on_B;
   wire [1:0] branch_data_forward_sel_A;
   wire [1:0] branch_data_forward_sel_B;
   
   wire [31:0] JALR_rs1_data;
		
    Control_Stall _cstall_ (
        .flush_signal(flush),
        .IF_ID_cstall(IF_ID_cstall)
        );
		
	branch_load_check B_L_stall (
		.inst_in(inst_in),
		.IF_ID_inst_in(IF_ID_inst_in),
		
        .branch_load_dstall(branch_load_dstall)
    );

    assign ALU_out = EXE_MEM_ALU_out;
    assign data_out = EXE_MEM_Data_out;
    assign mem_w = EXE_MEM_mem_w;
    
    // IF:-------------------------------------------------------------------------------------------
    // Control Signals:
    //   1. Branch - MUX5 : ID
    // References:
    //   1. inst_in - MUX5 : ID
    //   2. rdata_A - MUX5 : ID
    //   3. Imm_32 - ADD_Branch : ID
    // Pass-on:
    //   1. inst_in (combinatorial)
    //   2. PC
    // Out:
    //   1. PC_out: for fetching inst_in
    REG32 _pc_ (
        .CE(V5),
        .clk(clk),
        .D(PC_wb[31:0]),
        .rst(rst),
        .Q(PC[31:0]),
		.branch_load_dstall(branch_load_dstall)
        );
	branch_predict predict_module1(
		.clk(clk), .rst(rst), .CE(V5),
		.IF_instr(inst_in),
		.ID_instr(IF_ID_inst_in),
		.ID_PC(IF_ID_PC),
		.zero(zero),
		.PC_mux_sel(MUX5_sel[1:0]),
		.branch_PC_mux1_sel(IF_B_MUX1_sel),
		.branch_PC_mux2_sel(IF_B_MUX2_sel),
		.flush_signal(flush)
	);	
    add_32  ADD_Branch (
        .a(B_sel1_data[31:0]),         
        .b(B_sel2_data[31:0]),           
        .c(add_branch_out[31:0])   
        );   
    add_32 ADD_JAL (
        .a(IF_ID_PC[31:0]),               // MIPS: PC+4, RISC-V: PC!!!
        .b({{11{IF_ID_inst_in[31]}}, IF_ID_inst_in[31], IF_ID_inst_in[19:12], IF_ID_inst_in[20], IF_ID_inst_in[30:21], 1'b0}), 
        .c(add_jal_out[31:0])
        );
		
	assign JALR_rs1_data = Branch_data_ALU_A_2;
    add_32 ADD_JALR (
        .a(JALR_rs1_data[31:0]), 			
        .b({{20{IF_ID_inst_in[31]}}, IF_ID_inst_in[31:20]}), 
        .c(add_jalr_out[31:0])
        );
		
	Mux4to1b32 branch_sel1 (
		.I0(PC[31:0]),
		.I1(IF_ID_PC),
		.I2(),
		.I3(),
		.s(IF_B_MUX1_sel),
		.o(B_sel1_data[31:0])
		);
		
	Mux4to1b32 branch_sel2 (
		.I0(Imm_IF[31:0]),
		.I1(32'b0100),
		.I2(Imm_32[31:0]),
		.I3(),
		.s(IF_B_MUX2_sel),
		.o(B_sel2_data[31:0])
		);
		

		
	SignExt _signed_ext_IF_stage_ (
	.inst_in(inst_in),
	.imm_32(Imm_IF)
	 );
	
    Mux4to1b32  MUX5 (
        .I0(PC[31:0] + 32'b0100),   // From IF stage
        .I1(add_branch_out[31:0]),      // Containing "PC" from ID stage
        .I2(add_jal_out[31:0] + 32'b0100),         // From ID stage
        .I3(add_jalr_out[31:0] + 32'b0100),        // From ID stage
        .s(MUX5_sel[1:0]),               
        .o(PC_wb[31:0])
        );

	Mux4to1b32 PC_jump_sel_MUX (
		.I0(PC[31:0]),
		.I1(add_jal_out[31:0]),
		.I2(add_jalr_out[31:0]),
		.I3(),
		.s(PC_jump_sel),
		.o(PC_out)
		);
		
    REG_IF_ID _if_id_ (
        .clk(clk), .rst(rst), .CE(V5),
        .IF_ID_cstall(IF_ID_cstall),
		.branch_load_dstall(branch_load_dstall),
        // Input
        .inst_in(inst_in),
        .PC(PC_out),
        // Output
        .IF_ID_inst_in(IF_ID_inst_in),
        .IF_ID_PC(IF_ID_PC)
        );

   // ID:-------------------------------------------------------------------------------------------
   // From IF:
   //   1. inst_in
   //   2. PC
   // Control Signals:
   //   1. RegWrite - Regs : WB
   //   2. ALUSrc_A / ALUSrc_B (stops here)
   // References:
   //   None
   // Pass-on:
   //   1. inst_in
       //   Control_signals {
       //   2. ALU_Control
       //   3. DatatoReg
       //   4. mem_w
       //   5. RegWrite
       //   }
   //   6. ALU_A
   //   7. ALU_B
   //   8. Data_out
   //   9. PC
   // Out:
   //   None
   
    Get_rw_regs _rw_regs_ (
        .inst_in(IF_ID_inst_in[31:0]),
        .written_reg(IF_ID_written_reg),
        .read_reg1(IF_ID_read_reg1),
        .read_reg2(IF_ID_read_reg2)
        );
    Controler  Ctrl_Unit (
        // Input:
        .OPcode(IF_ID_inst_in[6:0]),
        .Fun1(IF_ID_inst_in[14:12]),
        .Fun2(IF_ID_inst_in[31:25]),
        .zero(zero),				//not used anymore
        // Output:
        .ALUSrc_A(ALUSrc_A),
        .ALUSrc_B(ALUSrc_B[1:0]),
        .ALU_Control(ALU_Control[4:0]),
        .PC_jump_sel(PC_jump_sel[1:0]),
        .DatatoReg(DatatoReg[1:0]),
        .mem_w(IF_ID_mem_w),
        .RegWrite(RegWrite),
		.LOAD_type(LOAD_type),
		.LOAD_sign(LOAD_sign),
		.STORE_type(STORE_type)
        );
        
//     Mux2to1b32_1 _alu_data_forward (
//        .I0(Wt_data[31:0]),
//        .I1(ID_EXE_ALU_out[31:0]),
//        .s(replace_data_to_alu_data),
////        .o(Wt_data_1[31:0])
//       );

    Regs U2 (.clk(clk),
             .rst(rst),
             .L_S(MEM_WB_RegWrite),             // From Write-Back stage
             .R_addr_A(IF_ID_inst_in[19:15]),   // ID
             .R_addr_B(IF_ID_inst_in[24:20]),   // ID
             .Wt_addr(Wt_addr[4:0]),            // From Write-Back stage
             .Wt_data(Wt_data[31:0]),           // From Write-Back stage
             .rdata_A(rdata_A[31:0]),
             .rdata_B(rdata_B[31:0])
             );
    SignExt _signed_ext_ (
    .inst_in(IF_ID_inst_in),
     .imm_32(Imm_32)
     );

    Mux2to1b32  _alu_source_A_ (
        .I0(rdata_A[31:0]),
        .I1(Imm_32[31:0]),   // not used 
        .s(ALUSrc_A),
        .o(ALU_A[31:0])
        );

    Mux4to1b32  _alu_source_B_ (
        .I0(rdata_B[31:0]),
        .I1(Imm_32[31:0]),
        .I2(),
        .I3(),
        .s(ALUSrc_B[1:0]),
        .o(ALU_B[31:0]
        ));

	
	Mux4to1b32  branch_DF_data_sel_A (
        .I0(EXE_MEM_ALU_out[31:0]),
        .I1(ID_EXE_ALU_out[31:0]),
        .I2(data_in[31:0]),
        .I3(),
        .s(branch_data_forward_sel_A),
        .o(Branch_data_ALU_A_1[31:0])
        );	
	
	Mux2to1b32_1 branch_DF_or_original_A (
        .I0(ALU_A[31:0]),
        .I1(Branch_data_ALU_A_1[31:0]),
        .s(branch_forwarding_on_A),
        .o(Branch_data_ALU_A_2[31:0])
    );	
	
  
    Mux4to1b32  branch_DF_data_sel_B (
        .I0(EXE_MEM_ALU_out[31:0]),
        .I1(ID_EXE_ALU_out[31:0]),
        .I2(data_in[31:0]),
        .I3(),
        .s(branch_data_forward_sel_B),
        .o(Branch_data_ALU_B_1[31:0])
        );	
	
	Mux2to1b32_1 branch_DF_or_original_B (
        .I0(ALU_B[31:0]),
        .I1(Branch_data_ALU_B_1[31:0]),
        .s(branch_forwarding_on_B),
        .o(Branch_data_ALU_B_2[31:0])
    );	    
    		
    
    ID_Zero_Generator _id_zero_ (
        .A(Branch_data_ALU_A_2[31:0]), 
        .B(Branch_data_ALU_B_2[31:0]), 
        .ALU_operation(ALU_Control), 
        .zero(zero)
        );

	assign IF_ID_Data_out = rdata_B;
	
    REG_ID_EXE _id_exe_ (
        .clk(clk), .rst(rst), .CE(V5), //.ID_EXE_dstall(ID_EXE_dstall),
        // Input
        .inst_in(IF_ID_inst_in),
        .PC(IF_ID_PC),
        //// To EXE stage, ALU Operands A & B
        .ALU_A(ALU_A),
        .ALU_B(ALU_B),
        //// To EXE stage, ALU operation control signal
        .ALU_Control(ALU_Control),
        //// To MEM stage, for sw instruction, data from rs2 register written into memory
        .Data_out(IF_ID_Data_out),
        //// To MEM stage, for sw instruction, memor write enable signal
        .mem_w(IF_ID_mem_w),
        //// To WB stage, for choosing different data written back to register file
        .DatatoReg(DatatoReg),
        //// To WB stage, register file write valid
        .RegWrite(RegWrite),

		.LOAD_type(LOAD_type),
		.STORE_type(STORE_type),
        .LOAD_sign(LOAD_sign),
		
		//// For Data Hazard
        .written_reg(IF_ID_written_reg), .read_reg1(IF_ID_read_reg1), .read_reg2(IF_ID_read_reg2),
        
        // Output
        .ID_EXE_inst_in(ID_EXE_inst_in),
        .ID_EXE_PC(ID_EXE_PC),
        .ID_EXE_ALU_A(ID_EXE_ALU_A),
        .ID_EXE_ALU_B(ID_EXE_ALU_B),
        .ID_EXE_ALU_Control(ID_EXE_ALU_Control),
        .ID_EXE_Data_out(ID_EXE_Data_out),
        .ID_EXE_mem_w(ID_EXE_mem_w),
        .ID_EXE_DatatoReg(ID_EXE_DatatoReg),
        .ID_EXE_RegWrite(ID_EXE_RegWrite),
		
		.ID_EXE_LOAD_type(ID_EXE_LOAD_type),
		.ID_EXE_STORE_type(ID_EXE_STORE_type),
        .ID_EXE_LOAD_sign(ID_EXE_LOAD_sign),
		
        //// For Data Hazard
        .ID_EXE_written_reg(ID_EXE_written_reg), .ID_EXE_read_reg1(ID_EXE_read_reg1), .ID_EXE_read_reg2(ID_EXE_read_reg2)
        );

    // EXE:-------------------------------------------------------------------------------------------
    // From ID:
    //   1. inst_in
        //   Control_signals {
        //   2. ALU_Control (stops here)
        //   3. mem_w
        //   4. DatatoReg
        //   5. RegWrite
        //   }
    //   6. ALU_A (stops here)
    //   7. ALU_B (stops here)
    //   8. Data_out
    //   9. PC
    // Control Signals:
    //   1. ALU_Control
    // References:
    //   None
    // Pass-on:
    //   1. inst_in
        //   Control_signals {
        //   2. DatatoReg (WB)
        //   3. mem_w (MEM)
        //   4. RegWrite (WB)
        //   }
    //   5. Data_out (used at MEM together with mem_w)
    //   6. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   7. PC
    // Out:
    //   None

    DF_control _aluctrl_ (
        .IF_ID_written_reg(IF_ID_written_reg),
        .IF_ID_read_reg1(IF_ID_read_reg1),
        .IF_ID_read_reg2(IF_ID_read_reg2),
        
        .ID_EXE_written_reg(ID_EXE_written_reg),
        .ID_EXE_read_reg1(ID_EXE_read_reg1),
        .ID_EXE_read_reg2(ID_EXE_read_reg2),
        
        .EXE_MEM_written_reg(EXE_MEM_written_reg),
        .EXE_MEM_read_reg1(EXE_MEM_read_reg1),
        .EXE_MEM_read_reg2(EXE_MEM_read_reg2),
        
        .ID_EXE_DatatoReg(ID_EXE_DatatoReg[1:0]),
        .EXE_MEM_DatatoReg(EXE_MEM_DatatoReg[1:0]),
        .IF_ID_DatatoReg(DatatoReg[1:0]),
        .IF_ID_mem_w(IF_ID_mem_w),
        .ID_EXE_mem_w(ID_EXE_mem_w),
        .EXE_MEM_mem_w(EXE_MEM_mem_w),       
        
        .clk(clk),
		.rst(rst),
        .ALU_forwarding_on_data_out(ALU_forwarding_on_data_out),
        .ALU_data_forward_sel_data_out(ALU_data_forward_sel_data_out),     
		.ALU_forwarding_on_A(ALU_forwarding_on_A),
		.ALU_forwarding_on_B(ALU_forwarding_on_B),
		.ALU_data_forward_sel_A(ALU_data_forward_sel_A),
		.ALU_data_forward_sel_B(ALU_data_forward_sel_B),
		.branch_forwarding_on_A(branch_forwarding_on_A),
		.branch_forwarding_on_B(branch_forwarding_on_B),
		.branch_data_forward_sel_A(branch_data_forward_sel_A),
		.branch_data_forward_sel_B(branch_data_forward_sel_B)
        );
		
	
    Mux4to1b32  DF_data_sel_A (
        .I0(EXE_MEM_ALU_out[31:0]),
        .I1(data_in[31:0]),
        .I2(MEM_WB_ALU_out[31:0]),
        .I3(MEM_WB_Data_in[31:0]),
        .s(ALU_data_forward_sel_A),
        .o(_alu_Source_A_1_ALU_A[31:0])
        );	
	
	Mux2to1b32_1 DF_or_original_A (
        .I0(ID_EXE_ALU_A[31:0]),
        .I1(_alu_Source_A_1_ALU_A[31:0]),
        .s(ALU_forwarding_on_A),
        .o(_alu_Source_A_2_ALU_A[31:0])
    );
  
    Mux4to1b32  DF_data_sel_B (
        .I0(EXE_MEM_ALU_out[31:0]),
        .I1(data_in[31:0]),
        .I2(MEM_WB_ALU_out[31:0]),
        .I3(MEM_WB_Data_in[31:0]),
        .s(ALU_data_forward_sel_B),
        .o(_alu_Source_B_1_ALU_B[31:0])
        );	
	
	Mux2to1b32_1 DF_or_original_B (
        .I0(ID_EXE_ALU_B[31:0]),
        .I1(_alu_Source_B_1_ALU_B[31:0]),
        .s(ALU_forwarding_on_B),
        .o(_alu_Source_B_2_ALU_B[31:0])
    );
        
    ALU _alualu_ (
        .A(_alu_Source_A_2_ALU_A[31:0]),
        .B(_alu_Source_B_2_ALU_B[31:0]),
        .ALU_operation(ID_EXE_ALU_Control[4:0]),
        .res(ID_EXE_ALU_out[31:0]),
        .overflow(),
        .zero()
        ); 

	   Mux4to1b32  DF_data_sel_data_out (
        .I0(EXE_MEM_ALU_out[31:0]),
        .I1(data_in[31:0]),
        .I2(MEM_WB_ALU_out[31:0]),
        .I3(MEM_WB_Data_in[31:0]),
        .s(ALU_data_forward_sel_data_out),
        .o(_data_out_Source[31:0])
        );	
       Mux2to1b32_1 DF_or_original_data_out (
        .I0(ID_EXE_Data_out[31:0]),
        .I1(_data_out_Source[31:0]),
        .s(ALU_forwarding_on_data_out),
        .o(_data_out_Source_1[31:0])
    );
        
	   STORE_extend S_ex1(
		.ID_EXE_Data_out_2(_data_out_Source_1),
		.ID_EXE_STORE_type(ID_EXE_STORE_type),

		.ID_EXE_Data_extended(ID_EXE_Data_extended)
		);	
        

    REG_EXE_MEM _exe_mem_ (
        .clk(clk), .rst(rst), .CE(V5),
        // Input
        .inst_in(ID_EXE_inst_in),
        .PC(ID_EXE_PC),
        //// To MEM stage
        .ALU_out(ID_EXE_ALU_out),
        .Data_out(ID_EXE_Data_extended),
        .mem_w(ID_EXE_mem_w),
        //// To WB stage
        .DatatoReg(ID_EXE_DatatoReg),
        .RegWrite(ID_EXE_RegWrite),
		
		.ID_EXE_LOAD_type(ID_EXE_LOAD_type),
        .ID_EXE_LOAD_sign(ID_EXE_LOAD_sign),
        
        .written_reg(ID_EXE_written_reg), .read_reg1(ID_EXE_read_reg1), .read_reg2(ID_EXE_read_reg2),
        
        // Output
        .EXE_MEM_inst_in(EXE_MEM_inst_in),
        .EXE_MEM_PC(EXE_MEM_PC),
        .EXE_MEM_ALU_out(EXE_MEM_ALU_out),
        .EXE_MEM_Data_out(EXE_MEM_Data_out),
        .EXE_MEM_mem_w(EXE_MEM_mem_w),
        .EXE_MEM_DatatoReg(EXE_MEM_DatatoReg),
        .EXE_MEM_RegWrite(EXE_MEM_RegWrite),
        
		.EXE_MEM_LOAD_type(EXE_MEM_LOAD_type),
        .EXE_MEM_LOAD_sign(EXE_MEM_LOAD_sign),
		
        .EXE_MEM_written_reg(EXE_MEM_written_reg), .EXE_MEM_read_reg1(EXE_MEM_read_reg1), .EXE_MEM_read_reg2(EXE_MEM_read_reg2)
        );

    // MEM:-------------------------------------------------------------------------------------------
    // From EXE:
    //   1. inst_in
        //   Control_signals {
        //   2. DatatoReg (WB)
        //   3. mem_w (stops here)
        //   4. RegWrite (WB)
        //   }
    //   5. Data_out (stops here)
    //   6. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   7. PC
    // Control Signals:
    //   1. mem_w
    // Pass-on:
    //   1. inst_in
        //   Control_signals {
        //   2. DatatoReg (WB)
        //   3. RegWrite (WB)
        //   }
    //   4. ALU_out (Addr_out outside) (used at both MEM and WB)
    //   5. PC
    //   6. Data_in
    // Out:
    //   Data_out & mem_w, ALU_out(as Addr_out)
	
	LOAD_extend L_ex1(
		//Comes from data memory
		.RAM_data(RAM_data_in),
		.EXE_MEM_LOAD_type(EXE_MEM_LOAD_type),
		.EXE_MEM_LOAD_sign(EXE_MEM_LOAD_sign),

		.data_in(data_in)
		);

    
    REG_MEM_WB _mem_wb_ (
        .clk(clk), .rst(rst), .CE(V5),
        // Input
        .inst_in(EXE_MEM_inst_in),
        .PC(EXE_MEM_PC),
        .ALU_out(EXE_MEM_ALU_out),
        .DatatoReg(EXE_MEM_DatatoReg),
        .RegWrite(EXE_MEM_RegWrite),
        //// Comes from LOAD_extend module
        .Data_in(data_in),
        
        // Output
        .MEM_WB_inst_in(MEM_WB_inst_in),
        .MEM_WB_PC(MEM_WB_PC),
        .MEM_WB_ALU_out(MEM_WB_ALU_out),
        .MEM_WB_DatatoReg(MEM_WB_DatatoReg),
        .MEM_WB_RegWrite(MEM_WB_RegWrite),
        .MEM_WB_Data_in(MEM_WB_Data_in)
        );

    // WB:-------------------------------------------------------------------------------------------
    // From EXE:
    //   1. inst_in
       //   Control_signals {
       //   2. DatatoReg (WB)
       //   3. RegWrite (WB)
       //   }
    //   4. ALU_out (Addr_out outside) (used at both MEM and WB)
    // Local:
    wire [31:0] LoA_data;

    assign Wt_addr[4:0] = MEM_WB_inst_in[11:7]; // rd, except for branch and store instructions
    LUI_or_AUIPC _loa_ (
        .inst_in(MEM_WB_inst_in[31:0]),
        .PC(MEM_WB_PC),
        .data(LoA_data[31:0])
        );
    Mux4to1b32  MUX3 (
        .I0(MEM_WB_ALU_out[31:0]),          // Others
        .I1(MEM_WB_Data_in[31:0]),          // Load
        .I2(LoA_data[31:0]),                // LUI and AUIPC
        .I3(MEM_WB_PC[31:0] + 32'b0100),    // jal and jalr: PC + 4
        .s(MEM_WB_DatatoReg[1:0]),
        .o(Wt_data[31:0]));
    
endmodule
