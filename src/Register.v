// Do not modify this file!

module Register (
    input clk,
    input rst,
    input regWrite,
    input [4:0] readReg1,
    input [4:0] readReg2,
    input [4:0] writeReg,
    input [31:0] writeData,
    output [31:0] readData1,
    output [31:0] readData2
);
    reg [31:0] regs [31:0];
    integer i;
    //Read
    assign readData1 = regs[readReg1];
    assign readData2 = regs[readReg2];
     
    always @(posedge clk) begin
        if(rst) begin
            for(i=0;i<32;i=i+1)begin
                regs[i]<=0;
            end
        end
    end
    //Write 
    always@(negedge clk)begin
        if(regWrite && writeReg!=0)begin
            regs[writeReg]<=writeData;
        end
    end
endmodule

