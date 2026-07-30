module InstructionMemory (
    input [31:0] readAddr,
    input reset,
    output [31:0] inst
);
    

    reg [7:0] insts [127:0];
    
    assign inst = (reset)? 32'h00000013:(readAddr >= 125)? 32'h00000013: {insts[readAddr], insts[readAddr + 1], insts[readAddr + 2], insts[readAddr + 3]};

    initial begin
        $readmemb("TEST_INSTRUCTIONS.dat", insts);
    end

endmodule

