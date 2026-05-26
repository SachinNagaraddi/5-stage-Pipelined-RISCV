module testbench(
);

    reg clk;
    reg reset;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        reset = 1;
        #10 reset = 0;
    end

    top dut (
        .clk(clk),
        .reset(reset)
    );