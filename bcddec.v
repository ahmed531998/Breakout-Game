`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    09:52:14 05/20/2017 
// Design Name: 
// Module Name:    bcddec 
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

module BCD_to_SEV(input [3:0] In, output reg [6:0] S);
//assuming the order a,b,c,d,e,f,g
always @ (In) begin
	case (In)
		4'd0:	S = 7'b000_0001;
		4'd1:	S = 7'b100_1111;
		4'd2:	S = 7'b001_0010;
		4'd3:	S = 7'b000_0110;
		4'd4:	S = 7'b100_1100;
		4'd5:	S = 7'b010_0100;
		4'd6:	S = 7'b010_0000;
		4'd7:	S = 7'b000_1111;
		4'd8:	S = 7'b000_0000;
		4'd9:	S = 7'b000_0100;
		
	default:	S = 7'b111_1111;
	endcase
end
endmodule