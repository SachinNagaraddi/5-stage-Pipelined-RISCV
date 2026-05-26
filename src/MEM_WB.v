module MEM_WB (
    input clk,
    input reset,

    // Data signals
    input [31:0] read_data_in,
    input [31:0] alu_result_in,

    // Register info
    input [4:0] rd_in,

    // Control signals
    input MemToReg_in,
    input RegWrite_in,

    // Outputs
    output reg [31:0] read_data_out,
    output reg [31:0] alu_result_out,
    output reg [4:0] rd_out,

    output reg MemToReg_out,
    output reg RegWrite_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        read_data_out <= 0;
        alu_result_out <= 0;
        rd_out <= 0;

        MemToReg_out <= 0;
        RegWrite_out <= 0;
    end else begin
        read_data_out <= read_data_in;
        alu_result_out <= alu_result_in;
        rd_out <= rd_in;

        MemToReg_out <= MemToReg_in;
        RegWrite_out <= RegWrite_in;
    end
end

endmodule