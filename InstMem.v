`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/14/2025 08:19:34 AM
// Design Name: 
// Module Name: InstMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module InstMem(
	input [6:0] addr,
	output [31:0] data_out
    );

	reg [31:0] mem [0:63];
	assign data_out = mem[addr];

	initial begin
//		mem[0] = 32'h00148493;
//		mem[1] = 32'h00290913;
//		mem[2] = 32'h00990933;
//		mem[3] = 32'hFFD98993;
//		mem[4] = 32'h012989B3;

        // R-type instructions
        mem[0] = 00010010001101000101000010110111;   
	end

endmodule
