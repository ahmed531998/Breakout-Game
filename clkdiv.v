`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:29:25 05/20/2017 
// Design Name: 
// Module Name:    clkdiv 
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
module clkdiv(input clk, input rst, output reg gclk);
    parameter f = 1'b1; 
    parameter in = 26'd50_000_000;

    reg[25:0] counter;
    always @ (posedge clk, posedge rst) begin
        if (rst) begin
            gclk <= 1'b0;
            counter <= 26'b1;
        end
        else begin
            if (counter == in/(2'd2*f)) begin
                gclk <= ~gclk;
                counter <= 26'b1;
            end
            else counter <= counter + 1'b1;
        end
    end
endmodule