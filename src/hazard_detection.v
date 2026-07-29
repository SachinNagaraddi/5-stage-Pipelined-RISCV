module hazard_unit(
  input [4:0] IF_ID_rs1,IF_ID_rs2,ID_EX_rd,
  input ID_EX_MemRead,Branch,zero
  output reg  stall,flush,flushE,PCSrc
);  
    always @(*) begin
        if (ID_EX_MemRead && (ID_EX_rd!=5'd0) && ((ID_EX_rd==IF_ID_rs1)||(ID_EX_rd==IF_ID_rs2)))
            stall = 1'b1;
        else
            stall = 1'b0;

        if(branch && zero)begin
            flush=1'b1;
            PCSrc=1'b1;
        end
        else begin
            flush=0;
            PCSrc=0;
        end

        if(PCSrc || stall)
            flushE=1'b1;
        else
            flushE=0;
    end
endmodule
