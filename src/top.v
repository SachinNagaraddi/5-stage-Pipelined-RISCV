module top(input clk,reset);

    // IF stage
    wire [31:0] pc,pc_plus4,pc_target,instruction,if_id_pc,if_id_inst;
    wire stall,PCSrc;

    pc pc_unit (
        .clk(clk),
        .reset(reset),
        .stall(stall),
        .pc_next(pc_next),
        .pc(pc)
    );

    Mux2to1 pc_select(
        .sel(PCSrc),
        .s0(pc_plus4),
        .s1(pc_target),
        .out(pc_next)
    );

    pc_adder pc4(
        .pc(pc),
        .step_size(32'd4),
        .pc_next(pc_plus4)
    );

    InstructionMemory instr_mem (
        .readAddr(pc),
        .inst(instruction)
    );

    IF_ID if_id_reg (
        .clk(clk),
        .reset(reset),
        .pc_in(pc),
        .inst_in(instruction),
        .stall(stall),
        .flush(branch_taken),
        .pc_out(if_id_pc),
        .inst_out(if_id_inst)
    );

    //ID stage
    wire [6:0] opcode;
    wire [4:0] rs1;
    wire [4:0] rs2;
    wire [4:0] rd;
    wire [2:0] funct3;
    wire [6:0] funct7;

    assign opcode = if_id_inst[6:0];
    assign rs1 = if_id_inst[19:15];
    assign rs2 = if_id_inst[24:20];
    assign rd  = if_id_inst[11:7];
    assign funct3 = if_id_inst[14:12];
    assign funct7 = if_id_inst[31:25];

    wire mem_wb_RegWrite;
    wire [4:0] mem_wb_rd;
    wire [31:0] mem_wb_data;
    wire [31:0] readData1;
    wire [31:0] readData2;
    
    ImmGen imm_gen (
        .inst(if_id_inst),
        .imm(imm)
    );

    Register reg_file (
        .clk(clk),
        .rst(reset),
        .regWrite(mem_wb_RegWrite),
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(mem_wb_rd),
        .writeData(wb_data),
        .readData1(readData1),
        .readData2(readData2)
    );

    wire cu_RegWrite;
    wire cu_MemWrite;
    wire cu_MemToReg;
    wire cu_ALUSrc;
    wire [1:0] cu_ALUOp;
    wire cu_Branch;

    control_unit CU (
        .opcode(opcode),
        .RegWrite(cu_RegWrite),
        .MemWrite(cu_MemWrite),
        .MemToReg(cu_MemToReg),
        .ALUSrc(cu_ALUSrc),
        .ALUOp(cu_ALUOp),
        .Branch(cu_Branch)
    );

    wire [31:0] id_ex_pc;
    wire [31:0] id_ex_rd1;
    wire [31:0] id_ex_rd2;
    wire [31:0] id_ex_imm;
    wire [2:0] id_ex_funct3;
    wire [6:0] id_ex_funct7;
    wire [4:0] id_ex_rs1;
    wire [4:0] id_ex_rs2;
    wire [4:0] id_ex_rd;
    wire id_ex_RegWrite;
    wire id_ex_MemWrite;
    wire id_ex_MemToReg;
    wire id_ex_ALUSrc;
    wire [1:0] id_ex_ALUOp;

    ID_EX id_ex_reg (
        .clk(clk),
        .reset(reset),
        .flush(flush),
        .pc_in(if_id_pc),
        .rd1_in(readData1),
        .rd2_in(readData2),
        .imm_in(imm),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .RegWrite_in(cu_RegWrite),
        .MemRead_in(cu_MemRead),
        .MemWrite_in(cu_MemWrite),
        .MemToReg_in(cu_MemToReg),
        .ALUSrc_in(cu_ALUSrc),
        .ALUOp_in(cu_ALUOp),
        .pc_out(id_ex_pc),
        .rd1_out(id_ex_rd1),
        .rd2_out(id_ex_rd2),
        .imm_out(id_ex_imm),
        .funct3_out(id_ex_funct3),
        .funct7_out(id_ex_funct7),
        .rs1_out(id_ex_rs1),
        .rs2_out(id_ex_rs2),
        .rd_out(id_ex_rd),
        .RegWrite_out(id_ex_RegWrite),
        .MemRead_out(id_ex_MemRead),
        .MemWrite_out(id_ex_MemWrite),
        .MemToReg_out(id_ex_MemToReg),
        .ALUSrc_out(id_ex_ALUSrc),
        .ALUOp_out(id_ex_ALUOp)
    );

    //EX stage
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    wire [31:0]A,mem_wb_data;
    wire [31:0] alu_result;
    wire zero;
    wire [3:0] ALU_ctrl;
    
    Mux2to1 Aoperand (
        .sel(ForwardA),
        .s0(id_ex_rd1),
        .s1(mem_wb_data);
        .out(A)
    );

    assign B=(id_ex_ALUSrc)? id_ex_imm:(ForwardB)? mwm_wb_data:id_ex_rd2;

    ALU execute_unit (
        .A(A),
        .B(B),
        .ALU_ctrl(ALU_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    alu_control ALU_CTRL_UNIT (
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .ALU_ctrl(ALU_ctrl)
    );
    
    wire [31:0] ex_mem_alu;
    wire [31:0] ex_mem_wdata;
    wire [4:0] ex_mem_rd;
    wire ex_mem_MemWrite;
    wire ex_mem_MemToReg;
    wire ex_mem_RegWrite;

    EX_MEM ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result),
        .write_data_in(B),
        .rd_in(id_ex_rd),
        .MemWrite_in(id_ex_MemWrite),
        .MemToReg_in(id_ex_MemToReg),
        .RegWrite_in(id_ex_RegWrite),
        .alu_result_out(ex_mem_alu),
        .write_data_out(ex_mem_wdata),
        .rd_out(ex_mem_rd),
        .MemWrite_out(ex_mem_MemWrite),
        .MemToReg_out(ex_mem_MemToReg),
        .RegWrite_out(ex_mem_RegWrite)
    );

    // MEM stage
    wire [31:0] mem_read_data;

    DataMemory data_mem (
        .rst(reset),
        .clk(clk),
        .memWrite(ex_mem_MemWrite),
        .address(ex_mem_alu),
        .writeData(ex_mem_wdata),
        .readData(mem_read_data)
    );

    wire [31:0] mem_wb_alu;
    wire mem_wb_MemToReg;

    MEM_WB mem_wb_reg (
        .clk(clk),
        .reset(reset),
        .read_data_in(mem_read_data),
        .alu_result_in(ex_mem_alu),
        .rd_in(ex_mem_rd),
        .MemToReg_in(ex_mem_MemToReg),
        .RegWrite_in(ex_mem_RegWrite),
        .read_data_out(mem_wb_data),
        .alu_result_out(mem_wb_alu),
        .rd_out(mem_wb_rd),
        .MemToReg_out(mem_wb_MemToReg),
        .RegWrite_out(mem_wb_RegWrite)
    );

    //WB stage
    Mux2to1 regdata(
        .sel(mem_wb_MemToReg),
        .s0(mem_wb_alu),
        .s1(mem_wb_data),
        .out(wb_data)
    );

    //Forwarding unit
    forwarding_unit FU (
        .EX_rs1(id_ex_rs1),
        .EX_rs2(id_ex_rs2),
        .MEM_rd(ex_mem_rd),
        .WB_rd(mem_wb_rd),
        .MEM_RegWrite(ex_mem_RegWrite),
        .WB_RegWrite(mem_wb_RegWrite),
        .ForwardA(ForwardA),
        .ForwardB(ForwardB)
    );

    //Hazard Unit
    
    
    assign branch_target = if_id_pc + imm;
    assign branch_taken = cu_Branch && (readData1 == readData2);

    hazard_detection HDU (
        .MemRead(id_ex_MemRead),
        .ID_EX_rd(id_ex_rd),
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .PCWrite(PCWrite),
        .IF_ID_Write(IF_ID_Write),
        .control_sel(control_sel)
    );

    assign pc_next = branch_taken ? branch_target : (PCWrite ? (pc + 4) : pc);
    
endmodule
