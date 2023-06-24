`timescale 1ns / 1ps


module testie(
	input clk,
	input rst,
	input start,
	input pause,
	input[1:0] background,
	input diff,
	input right,
	input left,
	output [7:0] rgbout,
	output [3:0] patt,
	output [6:0] live,
	output HS,
	output VS
);


reg [3:0] vx, vy;						
reg [8:0] timer;
wire [9:0] x, y;
reg [7:0] rgbinr;
wire [7:0] rgbin;
reg fail, win;
wire reset;
assign reset = rst || fail || ~start;

vgadriver vdriver(clk, rst, rgbin, rgbout, videoOn, x, y, HS, VS);

reg [0:19] circle; //x:[0:9], y:[10:19]
reg [0:29] rect; //x:[0:9], y:[10:19], w:[20:29]
reg [0:31] blocks = -1;
reg dirx, diry;
reg [3:0] px;
reg [5:0] coll;
integer i,j;

initial begin
	circle = {10'd300, 10'd250};
	coll = 0;
	dirx = 0;
	diry = 0; 	
	rect = {10'd300, 10'd400, 10'd100};
	vx = 1'd1;
	vy = 1'd1;
	px = 2;
end

assign rgbin = videoOn? rgbinr : 8'b0;

// rendering
always @(x,y) begin
		//check circles:
		//(x - x1)^2 + (y-y1)^2 <= r^2		else rgbinr = 8'b0;
			case (background)
			
			2'b00: rgbinr = 8'b0;
			2'b01: rgbinr = 8'd20;
			2'b10: rgbinr = 8'd80;
			2'b11: rgbinr = 8'd100;
			
			endcase
			
			if ((x-circle[0:9])*(x-circle[0:9]) + (y-circle[10:19])*(y-circle[10:19]) < 12'd64) //removing == for eff. 
				rgbinr = 8'd255;
			if (x > rect[0:9] && x < rect[0:9] + rect[20:29] && y > rect[10:19] && y < rect[10:19] + 6'd10) //removing == for eff.
				rgbinr = 8'd200;
			for (j = 1; j < 9; j = j+1) 
				for (i = 1; i < 5; i = i+1) 
					if (x > 64*j && x < 64*j+32 && y > 40*i && y < 40*i+20 && blocks[8*(i-1)+j-1]) //removing == for eff.
						rgbinr = 8'd55;
			if (pause) begin
				for (j = 1; j < 9; j = j+1) 
					for (i = 1; i < 5; i = i+1) 
						if (x > 64*j && x < 64*j+32 && y > 40*i && y < 40*i+20) //removing == for eff.
							rgbinr = i*j;
			end
			if (win) begin
				rgbinr = 8'd255;
				for (j = 1; j < 9; j = j+1) 
					for (i = 1; i < 10; i = i+1) 
						if (x > 64*j && x < 64*j+32 && y > 40*i && y < 40*i+20) //removing == for eff.
							rgbinr = 2*i*j+i+j;
			end
end

// clk dividers (one for the display, another for the timer
wire gclk;
clkdiv #(60) cd(clk, rst, gclk);
clkdiv #(1) ti(clk, rst, tclk);

// game timer
always @ (posedge tclk, posedge reset) begin
	if (reset) begin
		if (diff)
			timer <= 180;
		else
			timer <= 300;
	end
	else begin
		if (~pause) begin		
			timer <= timer - 1;
		end	
	end
end

// 7-segment display for the time
wire [3:0] a, b, c, d, interm;
BCD b2(timer, a, b,c,d);
BCD_to_SEV dec({5'b0,interm}, live);
wire [1:0] di;
SevDisplayDriver svdd(clk, 1'b1, reset, patt, di);
assign interm = di == 0? d :
				  di == 1? c :
				  di == 2? b : 0;

//GAME LOGIC

//paddle movement
always @(posedge gclk, posedge reset) begin
		if (reset) begin
			rect[0:9] <= 10'd300;
			if (diff) begin
				rect[20:29] <= 10'd76;
				px <= 3;	  //
			end
			else begin
				rect[20:29] <= 10'd100;
				px <= 2;
			end
		end
		else if (~pause) begin
			if (diff) begin
				case (coll) 
					6'd10: begin
						rect[20:29] <= 10'd60;
						px <= 4;	
					end
					6'd20: begin
						rect[20:29] <= 10'd50;
						px <= 5;	
					end
					6'd27: begin
						rect[20:29] <= 10'd35;
						px <= 6;	
					end
				endcase
			end
			
			else begin
				case (coll) 
					6'd10: begin
						rect[20:29] <= 10'd84;
						px <= 4;	
					end
					6'd20: begin
						rect[20:29] <= 10'd68;
						px <= 6;	
					end
					6'd27: begin
						rect[20:29] <= 10'd40;
						px <= 8;	
					end
				endcase
			end
		
			if (rect[0:9] < 640 - rect[20:29] && right) 
				rect[0:9] <= rect[0:9] + px;
			else if (rect[0:9] > px && left)  
				rect[0:9] <= rect[0:9] - px;
		end	
end

//ball motion
always @(posedge gclk, posedge reset) begin
	if (reset) begin 
			circle[0:9] <= 10'd300;
			circle[10:19]	<= 10'd200;
		if (~diff) begin
			vx = 1'd1;
			vy = 1'd1;
		end
		else begin
			vx = 3;
			vy = 3;
		end
	end
	else if (~pause) begin
		if (~diff) begin
			case (coll) 
				6'd10: begin
					vx = 2;
					vy = 2;
				end
				6'd20: begin
					vx = 3;
					vy = 3;
				end
				6'd27: begin
					vx = 4;
					vy = 4;	
				end
			endcase
		end
		
		else begin
			case (coll) 
				6'd10: begin
					vx = 4;
					vy = 4;
				end
				6'd20: begin
					vx = 5;
					vy = 5;
				end
				6'd27: begin
					vx = 5;
					vy = 5;	
				end
			endcase
	
		end
		
		if (~dirx)
			circle[0:9] <= circle[0:9] + vx;
		else
			circle[0:9] <= circle[0:9] - vx;
		if (~diry)
			circle[10:19]	<= circle[10:19] + vy;
		else
			circle[10:19]	<= circle[10:19] - vy;
	end
end

// collisions, fail, win
integer k, m;
always @(posedge gclk, posedge reset) begin
	if (reset) begin
		dirx <= 0;
		diry <= 0;
		fail <= 0;
		win <= 0;
		blocks <= -1;
		coll<=0;
	end
	else begin
		// border collisions, fail
		if (circle[0:9] > 10'd630 && ~dirx || circle[0:9] < 10 && dirx) 
			dirx <= ~dirx;
		if (circle [10:19] < 10 && diry) 
			diry <= 0;
		else if (circle[10:19] > rect[10:19]+30  && ~diry || !timer) begin
			fail <= 1;
		end

		// paddle collisons
		if (circle[0:9]+8 > rect[0:9] && circle[0:9] < rect[0:9] + (rect[20:29]/4) && circle[10:19] + 8 > rect[10:19]-3 && circle[10:19] + 8 < rect[10:19]+3 && ~diry) begin	
			diry <= ~diry;
			dirx <= 1;
		end
		if (circle[0:9] > rect[0:9] + (rect[20:29]/4) && circle[0:9] < rect[0:9] + 3*(rect[20:29]/4) && circle[10:19] + 8 > rect[10:19]-3 && circle[10:19] + 8 < rect[10:19]+3&& ~diry) begin	
			diry <= ~diry;
		end
		if (circle[0:9] > rect[0:9] + 3*(rect[20:29]/4) && circle[0:9] < rect[0:9] + rect[20:29]+16 && circle[10:19] + 8 > rect[10:19]-3 && circle[10:19] + 8 < rect[10:19]+3&& ~diry) begin	
			diry <= ~diry;
			dirx <= 0;
		end
		
		// blocks collisions
		for (k = 1; k < 9; k = k+1) 
			for (m = 1; m < 5; m = m+1) begin
					// left side 
							if (blocks[8*(m-1)+k-1] && circle[10:19] > 40*m-8/*-3*/ && circle[10:19] < 40*m+20+8/*3*/ && circle[0:9] /*+ 8*/ < 64*k/*+3*/ && circle[0:9] /*+ 8*/ > 64*k-8/*3*/ && ~dirx) begin
								blocks[8*(m-1)+k-1] <= 0;
								dirx <= ~dirx;
								coll <= coll + 1;
							end
							// right side
							if (blocks[8*(m-1)+k-1] && circle[10:19] > 40*m-8/*3*/ && circle[10:19] < 40*m+20+8/*3*/ && circle[0:9] /*- 8*/ > 64*k+32/*-3*/ && circle[0:9] /*- 8*/ < 64*k+32+8/*3*/ && dirx) begin
								blocks[8*(m-1)+k-1]<= 0;
								dirx <= ~dirx;
								coll <= coll + 1;
							end
						// top side
							if (blocks[8*(m-1)+k-1] && circle[0:9] < 64*k+32+8/*3*/ && circle[0:9] > 64*k-8/*3*/ && circle[10:19] /*+ 8*/ < 40*m/*+3*/ && circle[10:19] /*+ 8*/ > 40*m-8/*3*/ && ~diry) begin
								blocks[8*(m-1)+k-1]<= 0;
								diry <= ~diry;
								coll <= coll + 1;
							end
							// bottom side
							if (blocks[8*(m-1)+k-1] && circle[0:9] < 64*k+32+8/*3*/ && circle[0:9] > 64*k-8/*3*/ && circle[10:19] /*- 8*/< 40*m+20+8 && circle[10:19] > 40*m+20 /*- 8 > 40*m+20-3*/ && diry) begin
								blocks[8*(m-1)+k-1] <= 0;
								diry <= ~diry;
								coll <= coll + 1;
							end
			end
			
			// winning condition
			if (blocks == 0) win <= 1;
	end
end
endmodule 