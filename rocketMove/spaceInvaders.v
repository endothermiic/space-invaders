module spaceInvaders
	(
		CLOCK_50,						//	On Board 50 MHz
		// Your inputs and outputs here
		HEX0, 
		HEX2,
		KEY,
		SW,
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
	
	wire [7:0] xout;
	wire [6:0] yout;
	wire [2:0]colour;
	wire reset, clk, start, left, right, screenCleared, drewHomeBase, drawEn;
	
	rocket r0 (.reset(SW[0]), .clk(CLOCK_50), .start(~KEY[3]), .left(~KEY[2]), .right(~KEY[0]), .screenCleared(screenCleared), .drewHomeBase(drewHomeBase), .xout(xout), .yout(yout), .colourOut(colour), .drawEn(drawEn));
	

	// Create an Instance of a VGA controller - there can be only one!
	// Define the number of colours as well as the initial background
	// image file (.MIF) for the controller.
	vga_adapter VGA(
			.resetn(SW[0]),
			.clock(CLOCK_50),
			.colour(colour),
			.x(xout),
			.y(yout),
			.plot(drawEn),
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
			
	// Put your code here. Your code should produce signals x,y,colour and writeEn
	// for the VGA controller, in addition to any other functionality your design may require.

endmodule
