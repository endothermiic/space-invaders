//`include "mothership.v"

module rocket(reset, clk, start, left, right, screenCleared, drewHomeBase, xout, yout, colourOut, drawEn);
   parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
	parameter xStart = 8'd73; //start of 11x10 square
	parameter yStart = 7'd105;

   input reset, clk, start, left, right;
	
   output  [7:0] xout;  
	output  [6:0] yout;
	output  [2:0] colourOut;// VGA pixel coordinates
	output drawEn;
   output  screenCleared, drewHomeBase;
	wire leftEn, rightEn, screenClearEn, leftMoved, rightMoved;

	
	//TODO: leftMoved rightMoved
	
	//screencleared, rocketcleared assigned in control path
//	controlpath c0(.clk(clk), 
//						.reset(reset), //clear all 
//						.moveLeft(left),
//						.start(start), //put to centre of screen - if start high, makes plot high
//						.moveRight(right),
//						.screenCleared(screenCleared),
//						.rocketCleared(rocketCleared));

	//xout, yout, colourOut assigned in data path 
	datapath d0(.clk(clk), 
						.reset(reset), 
						.leftEn(leftEn),
						.rightEn(rightEn), //to move: clear, update x coord, redraw 
						.screenClearEn(screenClearEn),
						.screenCleared(screenCleared),
						.leftMoved(leftMoved), 
						.rightMoved(rightMoved),
						.drawEn(drawEn),
						.drewHomeBase(drewHomeBase),
						.xout(xout), 
						.yout(yout), 
						.colourOut(colourOut));
						
						
	controlpath c0 (.clk(clk), 
						.start(start), 
						.command_left(left), 
						.command_right(right), 
						.reset(reset),
						.screenCleared(screenCleared),
						.leftMoved(leftMoved), 
						.rightMoved(rightMoved),
						.screenClearEn(screenClearEn),
						.drewHomebase(drewHomeBase),
						.drawEn(drawEn),
						.leftEn(leftEn),
						.rightEn(rightEn));
						

endmodule // part2

//TODO - x, y fix coordinates, output 

module datapath (input clk, reset, leftEn, rightEn, screenClearEn, drawEn,
						output reg screenCleared, //changed
						output reg drewHomeBase, //changed
						output reg leftMoved,
						output reg rightMoved,
						output reg [7:0] xout, 
						output reg [6:0] yout, 
						output reg [2:0] colourOut);					
	parameter X_SCREEN_PIXELS = 8'd160;
   parameter Y_SCREEN_PIXELS = 7'd120;
	parameter xStart = 8'd73; //start of 11x10 square
	parameter yStart = 7'd105;
	
	reg [7:0] xorig = xStart; //shoudl start at xStart, yStart
	reg [6:0] yorig = yStart;
	
	reg [6:0] address = 6'b0;
	wire [2:0]shipColour;
	
	mothership u0 (.address(address), .clock(clk), .data(3'b0),	.wren(1'b0), .q(shipColour));
	
	
	reg rocketCleared = 1'b0, leftMovedCoord = 1'b0, rightMovedCoord = 1'b0;
	
							
	always@(posedge clk)
	begin
		if (reset) //active hight - TODO / fix
			begin
				xout <= 8'b0; 
				yout <= 7'b0;
				colourOut <= 3'b0;
				screenCleared <= 1'b0;
				drewHomeBase <= 1'b0;
				leftMoved <= 1'b0; 
				rightMoved <= 1'b0;
			end
		if (screenClearEn) //clears entire screen
			begin 
					if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
						begin
							screenCleared <= 1'b1;
							xout <= xorig; 
							yout <= yorig;
							drewHomeBase <= 1'b0;
						end
					else
						begin
							if (xout == 8'd159)
								begin 
									xout <= 8'b0;
									yout <= yout + 1;
								end
							else
								begin
									colourOut <= 3'b0; //set to all black
									xout <= xout + 1;
								end
						end
			end
			
		else if (screenCleared && ~leftEn && ~rightEn && ~drewHomeBase) //draws in default rocket
			begin
			//if xout < (xStart + 8'd10) && 
					if (yout < (yStart + 7'd9)) //check that xin is orig. !!
						begin
						if (xout == xStart + 8'd10)
							begin
								xout <= xStart; //reset to original
								yout <= yout + 1;
								colourOut <= shipColour;
								address <= address + 1;
								drewHomeBase <= 1'b0;	
							end
						else
							begin
								xout <= xout + 1;
								colourOut <= shipColour;
								address <= address + 1; 
								drewHomeBase <= 1'b0;	
							end
						end
					else
						begin
							drewHomeBase <= 1'b1;
							yout <= yorig;
							xout <= xorig;
							address <= 7'b0;
						end
			end
		
		else if (screenCleared && (leftEn || rightEn) && ~rocketCleared)
			begin
			//clear the original rocket
			if (yout < yorig + 7'd9) //check that xin is orig. !!
				begin
						if (xout == xorig + 8'd10)
							begin
								xout <= xorig; //reset to original
								yout <= yout + 1;
								colourOut <= 3'b0;
							end
						else
							begin
								xout <= xout + 1;
								colourOut <= 3'b0;	
							end
				end
			else 
				begin
					rocketCleared = 1'b1;
					drewHomeBase <= 1'b0;
				end
			end
		else if (screenCleared && (leftEn || rightEn) && rocketCleared)
			begin
				if (leftEn)
				begin
					if (!leftMovedCoord)
						begin
							xorig <= xorig - 5;
							xout <= xorig;
							yout <= yorig;
							leftMovedCoord <= 1'b1;
							drewHomeBase <= 1'b0;
						end
						
				
					else if (yout < yorig + 7'd10) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
						begin
						if (xout == xorig + 8'd10)
							begin
								xout <= xorig; //reset to original position
								yout <= yout + 1;
								colourOut <= shipColour;
								address <= address + 1;	
							end
						else
							begin
								xout <= xout + 1;
								colourOut <= shipColour;
								address <= address + 1; 
							end
						end
					
					
					else
						begin
							leftMoved <= 1'b1;
							address <= 7'b0;
						end
				end
				
				else if (rightEn)
				begin
				if (!rightMovedCoord)
					begin
						xorig <= xorig + 5;
						xout <= xorig;
						yout <= yorig;
						rightMovedCoord <= 1'b1;
						drewHomeBase <= 1'b0;
					end
				else if (yout < yorig + 7'd10) //check that xin is orig. !!
					begin
						if (xout == xorig + 8'd10)
							begin
								xout <= xorig; //reset to original position
								yout <= yout + 1;
								colourOut <= shipColour;
								address <= address + 1;
							end
						else
							begin
								xout <= xout + 1;
								colourOut <= shipColour;
								address <= address + 1; 
							end
					end
				elses
						begin
							address <= 7'b0;
							rightMoved <= 1'b1;
						end
			end
			ends
		else
			begin 
				leftMoved <= 1'b0;
				rightMoved <= 1'b0;
			end
	end
						
endmodule


module controlpath(clk,
							start,
							command_left,//from key
							command_right, //from key
							reset,  //from switch
							screenCleared,
							screenClearEn,
							drawEn,
							drewHomebase,
							leftEn,
							rightEn,
							leftMoved,
							rightMoved);
							
	input clk, start, command_left, command_right, reset, screenCleared, drewHomebase, leftMoved, rightMoved;
	output reg leftEn, rightEn, screenClearEn, drawEn;

	reg [2:0] current_state, next_state;
							
	localparam S_TITLE_PAGE = 4'd0, 
				  TITLE_WAIT = 4'd1,
				  S_CLEAR = 4'd2,
				  S_HOMEBASE = 4'd3,
				  S_COMMAND = 4'd4,
				  S_MOVE_LEFT = 4'd6,
				  S_LEFT_WAIT = 4'd5,
				  S_MOVE_RIGHT = 4'd7,
				  S_RIGHT_WAIT = 4'd8;
	
	//states for rocket control
	// COMMAND ready to take in a signal, MOVES will send out signals to the VGA Datapath
	always@(*)
	begin: state_table
		case (current_state)
						S_TITLE_PAGE: next_state = start ? TITLE_WAIT : S_TITLE_PAGE;
						TITLE_WAIT: next_state = start ? S_CLEAR : TITLE_WAIT;
						
						S_CLEAR: next_state = screenCleared ? S_HOMEBASE : S_CLEAR;
						
						S_HOMEBASE: next_state = drewHomebase ? S_COMMAND : S_HOMEBASE;
						
						S_COMMAND: //wait for input state
						begin
								if (command_left) next_state = S_MOVE_LEFT;
								else if (command_right) next_state = S_MOVE_RIGHT;
								else next_state = S_COMMAND;
						end
						S_LEFT_WAIT: next_state = leftMoved ? S_COMMAND : S_LEFT_WAIT;
						S_RIGHT_WAIT: next_state = rightMoved ? S_COMMAND : S_RIGHT_WAIT;
						S_MOVE_LEFT: next_state = leftMoved ? S_COMMAND : S_LEFT_WAIT;
						S_MOVE_RIGHT: next_state = rightMoved ? S_COMMAND : S_RIGHT_WAIT;
						
			default: next_state = S_HOMEBASE;
		endcase
	end
		//fixed
		//PROBLEM - after draws rocket.... drewHomeBase stays high; we need to reset back to zero, signal for moved left
	 always @(*)
    begin: enable_signals
		screenClearEn = 1'b0;
		leftEn = 1'b0;
		rightEn = 1'b0;
      drawEn = 1'b0;
	
		case (current_state)
				S_CLEAR: begin drawEn = 1'b1; screenClearEn = 1'b1; end
				S_TITLE_PAGE: drawEn = 1'b1;
				TITLE_WAIT: drawEn = 1'b1;
				S_COMMAND: drawEn = 1'b0;
				S_HOMEBASE: drawEn = 1'b1;
				S_MOVE_RIGHT:
					begin 
						rightEn = 1'b1;
						drawEn = 1'b1;
					end
				S_MOVE_LEFT:
					begin 
						leftEn = 1'b1;
						drawEn = 1'b1;
					end
				S_RIGHT_WAIT: 
					begin 
						rightEn = 1'b1;
						drawEn = 1'b1;
					end
				S_LEFT_WAIT:
					begin 
						leftEn = 1'b1;
						drawEn = 1'b1;
					end
		endcase			
	end
										
	always @ (posedge clk)
	begin: reset_conditions
	
		if(reset == 1'b1) 
			begin
				current_state = S_TITLE_PAGE;
			end
			
		else
			begin
				current_state <= next_state;
			end
	end	
endmodule
		

								

//module readRocket (input clk, output [3:0] colour);
//	wire [6:0] address = 6'b0;
//	for (int i = 0; i < 110; i = i + 1)
//	begin
//		mothership u0 (.address(address), .clock(clk), .data(3'b0),	.wren(1'b0), .q(colour));
//	end
//endmodule

