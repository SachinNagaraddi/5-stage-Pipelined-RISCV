// 5-Stage Pipelined RISC-V Processor
// Upgraded with hazard detection, forwarding, and ID-stage branch flush
module top;

    reg clk;
    reg reset;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset = 0;
    end

    // IF stage
    wire [31:0] pc;
    wire [31:0] pc_next;
    wire [31:0] instruction;

    // IF/ID stage
    wire [31:0] if_id_pc;
    wire [31:0] if_id_inst;
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

    // ID stage control outputs
    wire cu_RegWrite;
    wire cu_MemRead;
    wire cu_MemWrite;
    wire cu_MemToReg;
    wire cu_ALUSrc;
    wire [1:0] cu_ALUOp;
    wire cu_Branch;

    // Register file outputs
    wire [31:0] readData1;
    wire [31:0] readData2;

    // Hazard / branch handling
    wire PCWrite;
    wire IF_ID_Write;
    wire control_sel;
    wire branch_taken;
    wire [31:0] imm;
    wire [31:0] branch_target;

    // ID/EX stage
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
    wire id_ex_MemRead;
    wire id_ex_MemWrite;
    wire id_ex_MemToReg;
    wire id_ex_ALUSrc;
    wire [1:0] id_ex_ALUOp;

    // Forwarding controls
    wire [1:0] ForwardA;
    wire [1:0] ForwardB;

    // EX stage values
    reg [31:0] forwardedA_data;
    reg [31:0] forwardedB_data;
    wire [31:0] ALU_in1;
    wire [31:0] ALU_in2;
    wire [31:0] alu_result;
    wire zero;
    wire [3:0] ALU_ctrl;

    // EX/MEM stage
    wire [31:0] ex_mem_alu;
    wire [31:0] ex_mem_wdata;
    wire [4:0] ex_mem_rd;
    wire ex_mem_MemRead;
    wire ex_mem_MemWrite;
    wire ex_mem_MemToReg;
    wire ex_mem_RegWrite;

    // MEM/WB stage
    wire [31:0] mem_wb_alu;
    wire [31:0] mem_wb_data;
    wire [4:0] mem_wb_rd;
    wire mem_wb_MemToReg;
    wire mem_wb_RegWrite;
    wire [31:0] mem_read_data;
    wire [31:0] wb_data;

    pc pc_unit (
        .clk(clk),
        .reset(reset),
        .pc_next(pc_next),
        .pc(pc)
    );

    InstructionMemory instr_mem (
        .readAddr(pc),
        .inst(instruction)
    );

    control_unit CU (
        .opcode(opcode),
        .RegWrite(cu_RegWrite),
        .MemRead(cu_MemRead),
        .MemWrite(cu_MemWrite),
        .MemToReg(cu_MemToReg),
        .ALUSrc(cu_ALUSrc),
        .ALUOp(cu_ALUOp),
        .Branch(cu_Branch)
    );

    ImmGen imm_gen (
        .inst(if_id_inst),
        .imm(imm)
    );

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

    IF_ID if_id_reg (
        .clk(clk),
        .reset(reset),
        .pc_in(pc),
        .inst_in(instruction),
        .write_en(IF_ID_Write),
        .flush(branch_taken),
        .pc_out(if_id_pc),
        .inst_out(if_id_inst)
    );

    Register reg_file (
        .clk(clk),
        .rst(~reset),
        .regWrite(mem_wb_RegWrite),
        .readReg1(rs1),
        .readReg2(rs2),
        .writeReg(mem_wb_rd),
        .writeData(wb_data),
        .readData1(readData1),
        .readData2(readData2)
    );

    ID_EX id_ex_reg (
        .clk(clk),
        .reset(reset),
        .pc_in(if_id_pc),
        .rd1_in(readData1),
        .rd2_in(readData2),
        .imm_in(imm),
        .funct3_in(funct3),
        .funct7_in(funct7),
        .rs1_in(rs1),
        .rs2_in(rs2),
        .rd_in(rd),
        .RegWrite_in(control_sel ? 1'b0 : cu_RegWrite),
        .MemRead_in(control_sel ? 1'b0 : cu_MemRead),
        .MemWrite_in(control_sel ? 1'b0 : cu_MemWrite),
        .MemToReg_in(control_sel ? 1'b0 : cu_MemToReg),
        .ALUSrc_in(control_sel ? 1'b0 : cu_ALUSrc),
        .ALUOp_in(control_sel ? 2'b00 : cu_ALUOp),
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

    always @(*) begin
        case (ForwardA)
            2'b10: forwardedA_data = ex_mem_alu;
            2'b01: forwardedA_data = wb_data;
            default: forwardedA_data = id_ex_rd1;
        endcase
    end

    always @(*) begin
        case (ForwardB)
            2'b10: forwardedB_data = ex_mem_alu;
            2'b01: forwardedB_data = wb_data;
            default: forwardedB_data = id_ex_rd2;
        endcase
    end

    assign ALU_in1 = forwardedA_data;
    assign ALU_in2 = id_ex_ALUSrc ? id_ex_imm : forwardedB_data;

    alu_control ALU_CTRL_UNIT (
        .ALUOp(id_ex_ALUOp),
        .funct3(id_ex_funct3),
        .funct7(id_ex_funct7),
        .ALU_ctrl(ALU_ctrl)
    );

    ALU execute_unit (
        .A(ALU_in1),
        .B(ALU_in2),
        .ALU_ctrl(ALU_ctrl),
        .result(alu_result),
        .zero(zero)
    );

    EX_MEM ex_mem_reg (
        .clk(clk),
        .reset(reset),
        .alu_result_in(alu_result),
        .write_data_in(forwardedB_data),
        .rd_in(id_ex_rd),
        .MemRead_in(id_ex_MemRead),
        .MemWrite_in(id_ex_MemWrite),
        .MemToReg_in(id_ex_MemToReg),
        .RegWrite_in(id_ex_RegWrite),
        .alu_result_out(ex_mem_alu),
        .write_data_out(ex_mem_wdata),
        .rd_out(ex_mem_rd),
        .MemRead_out(ex_mem_MemRead),
        .MemWrite_out(ex_mem_MemWrite),
        .MemToReg_out(ex_mem_MemToReg),
        .RegWrite_out(ex_mem_RegWrite)
    );

    DataMemory data_mem (
        .rst(~reset),
        .clk(clk),
        .memWrite(ex_mem_MemWrite),
        .memRead(ex_mem_MemRead),
        .address(ex_mem_alu),
        .writeData(ex_mem_wdata),
        .readData(mem_read_data)
    );

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

    WB writeback_unit (
        .mem_wb_MemToReg(mem_wb_MemToReg),
        .mem_wb_read_data(mem_wb_data),
        .mem_wb_alu_result(mem_wb_alu),
        .write_back_data(wb_data)
    );

    initial begin
        $monitor("Cycle=%0t Final_Output=%d", $time, wb_data);
    end

    always @(posedge clk) begin
        $display("x1: %h x2: %h x3: %h x4: %h x5: %h",
            reg_file.regs[1],
            reg_file.regs[2],
            reg_file.regs[3],
            reg_file.regs[4],
            reg_file.regs[5]
        );
    end

    always @(posedge clk) begin
        $display("mem[112]: %h mem[116]: %h",
            data_mem.data_memory[112],
            data_mem.data_memory[116]
        );
    end

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, top);
        #200 $finish;
    end

endmodule