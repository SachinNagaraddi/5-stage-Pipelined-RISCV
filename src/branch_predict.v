module branch_predictor (
    input clk,
    input reset,
    input [31:0] fetch_pc,         // PC in the Fetch (IF) stage
    input update_en,               // High when a branch is resolved in ID stage
    input [31:0] update_pc,        // PC of the branch being resolved
    input [31:0] actual_target,    // The calculated target address
    input actual_taken,            // Actual outcome of the branch
    output reg predict_taken,
    output reg [31:0] predict_target
);
    // Simple 16-entry BTB arrays
    reg [31:0] btb_pc [0:15];
    reg [31:0] btb_target [0:15];
    reg btb_valid [0:15];
    reg btb_prediction [0:15]; 

    // Index using bits [5:2] of the PC
    wire [3:0] fetch_idx = fetch_pc[5:2];
    wire [3:0] update_idx = update_pc[5:2];

    // Prediction Logic (Combinational for the IF stage)
    always @(*) begin
        if (btb_valid[fetch_idx] && (btb_pc[fetch_idx] == fetch_pc)) begin
            predict_taken = btb_prediction[fetch_idx];
            predict_target = btb_target[fetch_idx];
        end else begin
            predict_taken = 1'b0;      // Default to Not Taken
            predict_target = 32'h0;
        end
    end

    // Update Logic (Synchronous update when branch result is known)
    integer i;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            for (i = 0; i < 16; i = i + 1) btb_valid[i] <= 1'b0;
        end else if (update_en) begin
            btb_pc[update_idx] <= update_pc;
            btb_target[update_idx] <= actual_target;
            btb_valid[update_idx] <= 1'b1;
            btb_prediction[update_idx] <= actual_taken;
        end
    end
endmodule