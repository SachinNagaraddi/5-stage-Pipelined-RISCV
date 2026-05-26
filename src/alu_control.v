module alu_control (
    input [1:0] ALUOp,
    input [2:0] funct3,
    input [6:0] funct7,

    output reg [3:0] ALU_ctrl
);

always @(*) begin
    case (ALUOp)

        // For lw, sw, addi
        2'b00: ALU_ctrl = 4'b0010; // ADD

        // For branch (beq)
        2'b01: ALU_ctrl = 4'b0110; // SUB

        // For R-type and I-type (arith/logic)
        2'b10: begin
            case (funct3)

                3'b000: begin
                    // ADD / SUB / ADDI
                    if (funct7 == 7'b0100000)
                        ALU_ctrl = 4'b0110; // SUB
                    else
                        ALU_ctrl = 4'b0010; // ADD
                end

                3'b111: ALU_ctrl = 4'b0000; // AND / ANDI
                3'b110: ALU_ctrl = 4'b0001; // OR / ORI
                3'b010: ALU_ctrl = 4'b0111; // SLT / SLTI

                default: ALU_ctrl = 4'b0000;
            endcase
        end

        default: ALU_ctrl = 4'b0000;

    endcase
end

endmodule