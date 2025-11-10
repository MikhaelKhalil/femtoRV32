`timescale 1ns / 1ps

module ALU #(parameter n = 8) (
	input [n-1:0] A,
	input [n-1:0] B,
	input [3:0] sel,
	output reg [n-1:0] result,
	output zeroFlag
    );
    
wire [n-1:0] add_result;
wire add_cout;

reg [n-1:0] complementedB;
always @(*) begin
    if (sel[2]) complementedB = ~B + 1;
    else complementedB = B;
end

RCA #(n) adder (
    .Num1(A),
    .Num2(complementedB),
    .Cout(add_cout),
    .Out(add_result)
);

always @ (*) begin
	case (sel)
		4'b0000: 
			result = A & B;
		4'b0001: 
			result = A | B;
		4'b0010: 
		  result = add_result;
		4'b0110: 
		  result = add_result;
		default:
		  result = 0;
	endcase
end

assign zeroFlag = ~| result;

endmodule
