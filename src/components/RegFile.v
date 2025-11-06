`timescale 1ns / 1ps

module RegFile (
	input clk,
	input rst,
	input [4:0] readReg1,
	input [4:0] readReg2,
	input [4:0] writeReg,
	input [31:0] writeData,
	input regWrite,
	output [31:0] readData1,
	output [31:0] readData2
    );

	reg [31:0] regFile [31:0];

	assign readData1 = regFile[readReg1];
	assign readData2 = regFile[readReg2];

    integer i;
	always @(posedge clk or posedge rst) begin
		if (rst) begin		
			for (i = 0; i < 32; i = i + 1) begin
				regFile[i] = 32'b0;
			end
		end
		else begin
			if (regWrite && writeReg != 5'b00000) regFile[writeReg] = writeData;
		end
	end

endmodule
