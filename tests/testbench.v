module testbench;

reg clk;
reg reset;

top dut(
    .clk(clk),
    .reset(reset)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 1;
    #10;
    reset = 0;
end

initial begin
    $dumpfile("wave.vcd");
    $dumpvars(0, testbench);

    #1000;
    $finish;
end

endmodule
