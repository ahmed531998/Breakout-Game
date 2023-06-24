`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:40:12 05/20/2017 
// Design Name: 
// Module Name:    sevdriver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

module SevDisplayDriver(
    input clk,
	 input en,
    input rst,
    output [3:0] selDigit,
	 output reg [1:0] di
);
	
	clkdiv #(200) cdiv(clk, rst, gclk);
		
	//modulo-4 bcounter
   always @ (posedge gclk, posedge rst) begin
		if (rst) di <= 0;
		else if (en) begin
			if (di == 3) di <= 0;
			else di <= (di + 1);	
		end
	end
	
	//2x4 decoder 
	 genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin:decoder
            assign selDigit[i:i] = ~(di  ==  i);
        end
    endgenerate	
endmodule


