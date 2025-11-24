`timescale 1ns / 1ps
`include "../../defines.v"

module BranchPredictor( 
    input clk, rst, 
    input [31:0] pc, //current pc we are predicting for
    input [31:0] update_pc, //pc of the branch instriction to update
    input actual_taken, //supposedly the actual branch outcome: 1 = taken, 0 =nt
    input update_enable, //enable update which is 1 when branch instruction completes

    output reg prediction
);


// using 64 entries (6 bits for the index)
parameter PREDICTOR_SIZE_LOG2 = 6;
parameter PREDICTOR_SIZE = (1 << PREDICTOR_SIZE_LOG2);

// states: 00 SNT, 01 WNT, 10 WT, 11 ST
// prediction would be the MSB of the counter

reg [1:0] predictor_table [0:PREDICTOR_SIZE-1];

// use lower bits of pc to index the table
wire [PREDICTOR_SIZE_LOG2-1:0] predict_index = pc[PREDICTOR_SIZE_LOG2+1:2];
wire [PREDICTOR_SIZE_LOG2-1:0] update_index  = update_pc[PREDICTOR_SIZE_LOG2+1:2];


// predict combinational
integer i;
initial begin
    for(i = 0; i < PREDICTOR_SIZE; i = i + 1)
        predictor_table[i] = 2'b01;  // weakly not-taken
end
always @(*) begin
    prediction = predictor_table[predict_index][1];  // MSB = predicted taken
end

// update sequential
always @(posedge clk or posedge rst) begin
    if (rst) begin
        for(i = 0; i < PREDICTOR_SIZE; i = i+1)
            predictor_table[i] <= 2'b01;
    end else if (update_enable) begin
        case (predictor_table[update_index])
            2'b00: begin // SNT
                if (actual_taken) predictor_table[update_index] <= 2'b01;
            end
            2'b01: begin // WNT
                predictor_table[update_index] <= actual_taken ? 2'b10 : 2'b00;
            end
            2'b10: begin // WT
                predictor_table[update_index] <= actual_taken ? 2'b11 : 2'b01;
            end
            2'b11: begin // ST
                if (!actual_taken)
                    predictor_table[update_index] <= 2'b10;
            end
        endcase
    end
end

endmodule