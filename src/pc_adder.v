module pc_adder(input [31:0]pc,step_size,output pc_next);

  assign pc_next=pc+step_size;

endmodule
