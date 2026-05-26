module ImmGen#(parameter Width = 32) (
    input [Width-1:0] inst,
    output reg signed [Width-1:0] imm
);

    wire [6:0] opcode = inst[6:0];

    always @(*) begin
        case(opcode)
            
            // I-type (addi, lw)
            7'b0010011,
            7'b0000011: 
                imm = {{20{inst[31]}}, inst[31:20]};

            // S-type (sw)
            7'b0100011:
                imm = {{20{inst[31]}}, inst[31:25], inst[11:7]};

            // B-type (branch)
            7'b1100011:
                imm = {{19{inst[31]}}, inst[31], inst[7],
                       inst[30:25], inst[11:8], 1'b0};

            default:
                imm = 32'b0;
        endcase
    end
            
endmodule