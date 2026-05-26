module ALU (
    input [31:0] A,
    input [31:0] B,
    input [3:0] ALU_ctrl,

    output reg [31:0] result,
    output zero
);

// ALU operations for RISC pipeline

always @(*) begin
    result = 32'b0; // default

    case(ALU_ctrl)
        4'b0010: result = A + B;       // addition
        4'b0110: result = A - B;       // subtraction
        4'b0000: result = A & B;       // and
        4'b0001: result = A | B;       // or
        4'b0111: result = (A < B);     // set less than
        default: result = 32'b0;
    endcase
end

assign zero = (result == 0);

endmodule