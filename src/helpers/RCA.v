`timescale 1ns / 1ps

module RCA #(parameter n = 8) (
	input [n-1:0] Num1,
	input [n-1:0] Num2,
	output Cout,
	output [n-1:0] Out
);

wire [n:0] cout_previous;
assign cout_previous[0] = 0;

generate
	genvar i;
	for(i = 0; i<n; i=i+1)
		begin
			FullAdder addition(.A(Num1[i]), .B(Num2[i]), .Cin(cout_previous[i]), .Sum(Out[i]), .Cout(cout_previous[i+1]));			
		end
endgenerate

assign Cout = cout_previous[n];

endmodule
