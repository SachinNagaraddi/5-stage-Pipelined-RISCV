module WB(
    input mem_wb_MemToReg,
    input [31:0] mem_wb_read_data,
    input [31:0] mem_wb_alu_result,
    output [31:0] write_back_data
);

assign write_back_data = (mem_wb_MemToReg) ? 
                         mem_wb_read_data : 
                         mem_wb_alu_result;

endmodule