module forwarding_unit(
    input [4:0] EX_rs1, EX_rs2,
    input [4:0] MEM_rd, WB_rd,
    input MEM_RegWrite, WB_RegWrite,
    output reg [1:0] ForwardA, ForwardB
);

always @(*) begin
    ForwardA = 2'b00;
    ForwardB = 2'b00;

    if (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rs1))
        ForwardA = 2'b10;

    if (MEM_RegWrite && (MEM_rd != 0) && (MEM_rd == EX_rs2))
        ForwardB = 2'b10;

    if (WB_RegWrite && (WB_rd != 0) && !(MEM_RegWrite && (MEM_rd == EX_rs1)) && (WB_rd == EX_rs1))
        ForwardA = 2'b01;

    if (WB_RegWrite && (WB_rd != 0) && !(MEM_RegWrite && (MEM_rd == EX_rs2)) && (WB_rd == EX_rs2))
        ForwardB = 2'b01;
end

endmodule