module DataMemory(
	input rst,
	input clk,
	input memWrite,
	input [31:0] address,
	input [31:0] writeData,
	output [31:0] readData
);
	
	reg [7:0] data_memory [127:0];
	integer i;
	
	assign readData=(address<125)? {data_memory[address+3],data_memory[address+2],data_memory[address+1],data_memory[address]}:32'b0;
	
	always @ (posedge clk) begin
		if(rst) begin
			for(i=0;i<128;i++)begin
				data_memory[i]<=0;
			end
		end
		else begin
			if(memWrite) begin
				data_memory[address + 3] <= writeData[31:24];
				data_memory[address + 2] <= writeData[23:16];
				data_memory[address + 1] <= writeData[15:8];
				data_memory[address]     <= writeData[7:0];
			end
		end
	end     
endmodule

