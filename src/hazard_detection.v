module hazard_detection(
    input MemRead,
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    output reg PCWrite,
    output reg IF_ID_Write,
    output reg control_sel
);

always @(*) begin
    if (MemRead && ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) begin
        PCWrite = 0;
        IF_ID_Write = 0;
        control_sel = 1;
    end else begin
        PCWrite = 1;
        IF_ID_Write = 1;
        control_sel = 0;
    end
end

endmodule