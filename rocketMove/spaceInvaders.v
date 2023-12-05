//`include "vga_controller.v"
//`include "vga_address_translator.v"
//`include "vga_pll.v"
//`include "vga_adapter.v"

module spaceInvaders
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		HEX0, 
		HEX2,
		HEX4,
		KEY,
		SW,
		LEDR,
   		// On Board Keys
		// The ports below are for the VGA output.  Do not change.
		VGA_CLK,   						//	VGA Clock
		VGA_HS,							//	VGA H_SYNC
		VGA_VS,							//	VGA V_SYNC
		VGA_BLANK_N,						//	VGA BLANK
		VGA_SYNC_N,						//	VGA SYNC
		VGA_R,   						//	VGA Red[9:0]
		VGA_G,	 						//	VGA Green[9:0]
		VGA_B   						//	VGA Blue[9:0]
	);

	input			CLOCK_50;				//	50 MHz
	output [7:0]HEX0;
	output [7:0]HEX2;
	output [7:0]HEX4;
	output [9:0] LEDR;
	input [3:0]KEY;
	input [6:0]SW;

	// Do not change the following outputs
	output			VGA_CLK;   				//	VGA Clock
	output			VGA_HS;					//	VGA H_SYNC
	output			VGA_VS;					//	VGA V_SYNC
	output			VGA_BLANK_N;				//	VGA BLANK
	output			VGA_SYNC_N;				//	VGA SYNC
	output	[7:0]	VGA_R;   				//	VGA Red[7:0] Changed from 10 to 8-bit DAC
	output	[7:0]	VGA_G;	 				//	VGA Green[7:0]
	output	[7:0]	VGA_B;   				//	VGA Blue[7:0]
	

	
	// Create the colour, x, y and writeEn wires that are inputs to the controller.
	
	wire [7:0] r_xout, b_xout, a_xout;
	wire [6:0] r_yout, b_yout, a_yout;
	wire [2:0] r_colour, b_colour, a_colour;
	wire  clk, a_enable, b_enable, screenCleared, drewHomeBase, clearAny;
	wire r_drawEn, b_drawEn, a_drawEn, gameOver, youWin, clear1, clear2, clear3, clear4, clear5, moveDown, movedDown, cleared1, cleared2, cleared3, cleared4, cleared5;
	wire [7:0] alienTopX, alienBottomX; 
	wire [6:0] alientopY, alienBottomY;
	wire [2:0] scoreCount;
	
	wire reset, start, left, right, shot, collidedWithAlien; 
	wire [4:0] curState;
	assign reset = ~SW[0];
	assign start = ~KEY[3];
	assign left = ~KEY[2];
	assign shot = ~KEY[1];
	assign right = ~KEY[0];
	assign LEDR[1] = start;
	
   rocket r0 (.reset(reset), .clk(clk), .start(start), .left(left), .right(right), 
   .screenCleared(LEDR[0]), .drewHomeBase(LEDR[9]), .xout(r_xout), .yout(r_yout), .colourOut(r_colour), .drawEn(r_drawEn), .curState(curState));

	hex_decoder c9 (.c(r_drawEn), .display(HEX0)); 
	hex_decoder c10 (.c(r_xout), .display(HEX2)); 
	hex_decoder c11 (.c(curState), .display(HEX4)); //for debugging!
	
	      
  shots s0 (.clk(clk), .keyPressed(shot), .reset(reset), .xin(r_xout), .bulletX(b_xout), .bulletY(b_yout), .colour(b_colour), .drawEn(b_drawEn), .collidedWithAlien(collidedWithAlien));
	
  aliens (.clk(clk), .reset(reset), .xout(a_xout), .yout(a_yout), .colourOut(a_colour), .a_drawEn(a_drawEn), .shotXCoord(b_xout), .shotYCoord(b_yout), .score(scoreCount), .collidedWithAlien(collidedWithAlien));
	
		
	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	
//		vga_adapter VGA(
//			.resetn(~SW[0]),
//			.clock(CLOCK_50),
//			.colour(r_colour),
//			.x(r_xout),
//			.y(r_yout),
//			.plot(r_drawEn),
//			/* Signals for the DAC to drive the monitor. */
//			.VGA_R(VGA_R),
//			.VGA_G(VGA_G),
//			.VGA_B(VGA_B),
//			.VGA_HS(VGA_HS),
//			.VGA_VS(VGA_VS),
//			.VGA_BLANK(VGA_BLANK_N),
//			.VGA_SYNC(VGA_SYNC_N),
//			.VGA_CLK(VGA_CLK));
//		defparam VGA.RESOLUTION = "160x120";
//		defparam VGA.MONOCHROME = "FALSE";
//		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
//		defparam VGA.BACKGROUND_IMAGE = "newHome.mif";
//	
	vga_adapter VGA(
			.resetn(~SW[0]),
			.clock(CLOCK_50),
			.colour(a_drawEn ? a_colour : r_drawEn ? r_colour : b_drawEn ? b_colour :0),
			.x(a_drawEn ? a_xout : r_drawEn ? r_xout : b_drawEn ? b_xout :0),
			.y(a_drawEn ? a_yout : r_drawEn ? r_yout : b_drawEn ? b_yout :0),
			.plot(a_drawEn | r_drawEn | b_drawEn),
			/* Signals for the DAC to drive the monitor. */
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "newHome.mif";
////			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.

endmodule
