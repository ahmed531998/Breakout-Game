`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:27:33 05/20/2017 
// Design Name: 
// Module Name:    BCD 
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
module BCD(
    input [13:0] bnum, //from 0000 to 9999
    output reg [3:0] a, //thous     //(abcd)_10
    output reg [3:0] b, //hund
    output reg [3:0] c, //tens
    output reg [3:0] d //units
);
    integer i;
    always @ (bnum) begin
        a = 4'b0;
        b = 4'b0;
        c = 4'b0;
        d = 4'b0;

        for (i = 13; i >= 0; i = i - 1) begin
            if (a >= 3'd5) a = a + 2'd3; // latching
            if (b >= 3'd5) b = b + 2'd3;
            if (c >= 3'd5) c = c + 2'd3;        
            if (d >= 3'd5) d = d + 2'd3;
            
            a = a << 1; a[0] = b[3];
            b = b << 1; b[0] = c[3];
            c = c << 1; c[0] = d[3];
            d = d << 1; d[0] = bnum[i]; // equiv to bnum = bnum << 1;

        end
    end
endmodule