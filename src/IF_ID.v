module IF_ID(
    input clk,
    input reset,

    input [31:0] pc_in,
    input [31:0] inst_in,
    input write_en,
    input flush,

    output reg [31:0] pc_out,
    output reg [31:0] inst_out
);

always @(posedge clk or posedge reset) begin
    if (reset) begin
        pc_out   <= 32'b0;
        inst_out <= 32'b0;
    end else if (flush) begin
        pc_out   <= 32'b0;
        inst_out <= 32'b0;
    end else if (write_en) begin
        pc_out   <= pc_in;
        inst_out <= inst_in;
    end else begin
        pc_out   <= pc_out;
        inst_out <= inst_out;
    end
end

endmodule