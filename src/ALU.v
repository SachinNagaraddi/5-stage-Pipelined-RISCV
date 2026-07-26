module ALU (
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_ctrl,

    output reg [31:0] result,
    output zero,overflow,negative,
    output reg carry
);
always @(*) begin
    carry=0;
    case(ALU_ctrl)
        4'b0010: {carry,result} = A + B;       // addition
        4'b0110: {carry,result} = A - B;       // subtraction
        4'b0000: result = A & B;       // and
        4'b0001: result = A | B;       // or
        4'b0111: result = ($signed(A) < $signed(B))? 32'd1 : 32'd0;     // set less than
        default: result = 32'b0;
    endcase
end

assign zero=(result == 0);
assign negative=result[31];
assign overflow=(~ALU_ctrl[2])&(A[31]^result[31])&(~(ALU_ctrl[2]^A[31]^B[31]));

endmodule
