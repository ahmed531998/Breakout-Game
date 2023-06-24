`timescale 1ns / 1ps

module vgadriver
	(
		input clk, input rst,
		input [7:0] rgbin,
		output [7:0] rgbout,
		output videoOn,
		output reg [9:0] x, 
		output reg [9:0] y,
		output HS, output VS
	);
	localparam width = 640;
	localparam height = 480;
	
	localparam borderWR = 16;
	localparam borderWL = 48;
	localparam hRetrace = 96;
	
	localparam borderHT = 10;
	localparam borderHB = 33;
	localparam vRetrace = 2;
	
	localparam maxWidth = width + borderWR + borderWL + hRetrace - 1;
	localparam maxHeight = height + borderHT + borderHB + vRetrace - 1;
		
	localparam hRetraceStart = width + borderWR;
	localparam vRetraceStart = height + borderHB;
	
	localparam hRetraceEnd = hRetraceStart + hRetrace - 1;
	localparam vRetraceEnd = vRetraceStart  + vRetrace - 1;
		
	//clkdiv by 2
	
	reg gclk;
	always @ (posedge clk, posedge rst) begin
		if (rst) gclk <= 0;
		else gclk <= ~gclk;
	end

	
	//pixel trackers

	always @ (posedge gclk, posedge rst) begin
		if (rst) begin
			y <= 0;
			x <= 0;
		end
		else begin
			y <= (x == maxWidth) ? (y == maxHeight ? 0 : y + 1) : y;
			x <= (x == maxWidth) ? 0 : x + 1;
		end
	end

	assign videoOn = (x < width) && (y < height); //
		
	//HS and VS (active low)
	assign HS = (x >= hRetraceStart) && (x <= hRetraceEnd);
	assign VS = (y >= vRetraceStart) && (y <= vRetraceEnd);
	assign rgbout = (videoOn)? rgbin : 8'b0; //
endmodule
	