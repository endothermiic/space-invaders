//Top level module for L/R rocket movement - includes control path and datapath
//Outputs drawEn, colour, and x/y coordinates for VGA adapter

//(sometimes required for Modelsim simulation - includes memory blocks (ROM))
//`include "title.v"
//`include "gameovernew.v"
//`include "mothership.v"

module rocket (reset, clk, start, left, right, screenCleared, drewHomeBase, xout, yout, colourOut, drawEn);
    parameter X_SCREEN_PIXELS = 8'd160;
    parameter Y_SCREEN_PIXELS = 7'd120;
	parameter xStart = 8'd73; //start of 11x10 square
	parameter yStart = 7'd105;
    input reset, clk, start, left, right;
	
   output  [7:0] xout;  
	output  [6:0] yout;
	output  [2:0] colourOut; 
	output drawEn, screenCleared, drewHomeBase;
	wire inIntake, leftEn, rightEn, screenClearEn, rocketClearLEn, rocketClearREn, rocketDrawEn, gameOverEn, titlePageEn, leftMoved, rightMoved, rocketCleared, drewGameOver, hitEdge, yset;

	//xout, yout, colourOut assigned in data path 
	datapath d0(.clk(clk), 
						.reset(reset), 
						.leftEn(leftEn),
						.rightEn(rightEn), 
						.screenClearEn(screenClearEn),
						.screenCleared(screenCleared),
						.rocketClearLEn(rocketClearLEn),
						.rocketClearREn(rocketClearREn),
						.rocketCleared(rocketCleared),
						.yset(yset),
						.gameOverEn(gameOverEn),
						.rocketDrawEn(rocketDrawEn),
						.titlePageEn(titlePageEn),
						.inIntake(inIntake),
						.leftMoved(leftMoved), 
						.rightMoved(rightMoved),
						.drawEn(drawEn),
						.drewHomeBase(drewHomeBase),
						.drewGameOver(drewGameOver),
						.hitEdge(hitEdge),
						.xout(xout), 
						.yout(yout), 
						.colourOut(colourOut));
						
						
	controlpath c0 (.clk(clk), 
						.start(start), 
						.drewGameOver(drewGameOver),
						.hitEdge(hitEdge),
						.command_left(left), 
						.command_right(right), 
						.reset(reset),
						.screenCleared(screenCleared),
						.rocketCleared(rocketCleared),
						.rocketClearLEn(rocketClearLEn),
						.rocketClearREn(rocketClearREn),
						.rocketDrawEn(rocketDrawEn),
						.gameOverEn(gameOverEn),
						.titlePageEn(titlePageEn),
						.leftMoved(leftMoved), 
						.rightMoved(rightMoved),
						.screenClearEn(screenClearEn),
						.drewHomebase(drewHomeBase),
						.drawEn(drawEn),
						.leftEn(leftEn),
						.rightEn(rightEn),
						.inIntake(inIntake),
						.yset(yset));
						

endmodule 

module datapath (input clk, reset, leftEn, rightEn, screenClearEn, drawEn, rocketClearLEn, rocketClearREn, gameOverEn, titlePageEn, rocketDrawEn, inIntake, yset,
						output reg screenCleared, 
						output reg drewHomeBase, 
						output reg leftMoved,
						output reg rightMoved,
						output reg rocketCleared,
						output reg hitEdge, 
						output reg drewGameOver,
						output reg [7:0] xout, 
						output reg [6:0] yout, 
						output reg [2:0] colourOut);					
	parameter X_SCREEN_PIXELS = 8'd160; //screen width
   	parameter Y_SCREEN_PIXELS = 7'd120; //screen height
	parameter xStart = 8'd73; //start of 11x10 square
	parameter yStart = 7'd105;
	
	reg [7:0] xorig = xStart; //original x/y positions
	reg [6:0] yorig = yStart;
	
	reg [6:0] address = 7'b0; //accounts for 1 cycle delay in reading from ROM
    reg [14:0]addressFS = 15'b0;

	wire [2:0]shipColour;
	wire [2:0]titlePageColour;
	wire [2:0]gameOverColour;
	
	mothership u0 (.address(address), .clock(clk), .data(3'b0),	.wren(1'b0), .q(shipColour)); //has rocket mif data (11x10)
  	g g0 (.clock(clk), .address(addressFS), .q(gameOverColour)); //has game over mif data (fullscreen)
	title t0 (.address(addressFS), .clock(clk), .q(titlePageColour)); //has title page mif data (fullscreen)
	
	reg leftMovedCoord = 1'b0, rightMovedCoord = 1'b0, titlePageDrew = 1'b0;
	
							
	always@(posedge clk)
	begin
		if (~reset) //active low reset, reset all signals to 0
			begin
				xout <= 8'b0; 
				yout <= 7'b0;
				colourOut <= 3'b0;
				screenCleared <= 1'b0;
				rocketCleared <= 1'b0;
				drewHomeBase <= 1'b0;
				leftMoved <= 1'b0; 
				rightMoved <= 1'b0;
				hitEdge <= 1'b0; 
				drewGameOver <= 1'b0;
			end

		if (screenClearEn) begin //if KEY[3] pushed, screenClearEn is high (from controlpath) and entire screen cleared 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					screenCleared <= 1'b1;
					xout <= xorig; 
					yout <= yorig;
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
			
		else if (rocketDrawEn) begin //draws defualt rocket in centre of screen
			if (yout < (yStart + 7'd10)) //Our rocket is 11 (x) by 10 (y) - y increments from 0 to 9
				begin
				if (xout == xStart + 8'd10)
					begin
						xout <= xStart; //reset to original position
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
					drewHomeBase <= 1'b1;
					yout <= yorig;
					xout <= xorig;
					address <= 7'b0;
				end
		end
		
		else if (inIntake) begin //reset all to 0 - we are waiting for next input from board
			leftMoved <= 1'b0;
			rightMoved <= 1'b0;
			rocketCleared <= 1'b0;
			drewHomeBase <= 1'b0;
			address <= 1'b0;
			leftMovedCoord <= 1'b0;
			rightMovedCoord <= 1'b0;
			colourOut <= 3'b0;
		end

		else if (yset) begin yout <= yorig; end

		else if (rocketClearLEn || rocketClearREn) begin //clear rocket in original position
			if (yout < yorig + 7'd10) 
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
			else begin 
				yout <= yorig;
				if (rocketClearLEn) xout <= xout - 8; 
				if (rocketClearREn) xout <= xout + 1; //accounts for 2 extra clk cycles to read from memory
				rocketCleared <= 1'b1;
			end
		end

		else if (leftEn) begin //move rocket to left by 5 pixels
			if (!leftMovedCoord) //sets original coordinates for x,y
				begin
					xorig <= xorig - 5;
					xout <= xout - 5;
					yout <= yorig;
					leftMovedCoord <= 1'b1;
				end
			
			if (address == 7'd1) begin colourOut <= shipColour; xout <= xorig; address <= address + 1; end 
			else if (yout < yorig + 7'd10) 
				begin
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
				end
			else if (xout < 8'd4) begin hitEdge <= 1; xout <= 8'b0; yout <= 7'b0; end
			else begin leftMoved <= 1'b1; colourOut <= 3'b0; end 
			
		end
				
		else if (rightEn) begin			
			if (!rightMovedCoord)
				begin
					xorig <= xorig + 5;
					xout <= xout + 5;
					yout <= yorig;
					rightMovedCoord <= 1'b1;
				end
			
			if (address == 7'd1) begin colourOut <= shipColour; xout <= xorig; address <= address + 1; end 
			else if (yout < yorig + 7'd10) 
					begin
					if (xout == xorig + 8'd10)
						begin
							xout <= xorig; 
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
			else if (xout > 8'd160) begin hitEdge <= 1; xout <= 8'b0; yout <= 7'b0; end
			else rightMoved <= 1'b1;
		end

		else if (gameOverEn) begin
			if (addressFS == 15'd1) begin colourOut <= gameOverColour; xout <= 8'b0; addressFS <= addressFS + 1; end //accounts for delay in reading from ROM
			if (addressFS == 8'd19199) addressFS <= 15'd0;
			else if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= 7'd0;
					drewGameOver <= 1'b1;
					addressFS <= 15'b0;
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
						end
					else
						begin
							colourOut <= gameOverColour; 
							xout <= xout + 1;
							addressFS <= addressFS + 1;
						end
				end
		end

		else if (titlePageEn && ~titlePageDrew) begin
			if (addressFS == 15'd1) begin colourOut <= titlePageColour; xout <= 8'b0; addressFS <= addressFS + 1; end //accounts for delay in reading from ROM
			if (addressFS == 8'd19199) addressFS <= 15'd0;
			else if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= 7'd0;
					titlePageDrew <= 1'b1;
					addressFS <= 15'b0;
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
						end
					else
						begin
							colourOut <= titlePageColour; 
							xout <= xout + 1;
							addressFS <= addressFS + 1;
						end
				end
		end
	end
						
endmodule


module controlpath #(parameter CLOCK_FREQUENCY = 50) (clk,
							start,
							drewGameOver,
							hitEdge,
							command_left,//from key[2]
							command_right, //from key[0]
							reset,  //from switch
							screenCleared,
							rocketCleared,
							drewHomebase,
							leftEn,
							rightEn,
							screenClearEn,
							rocketClearLEn,
							rocketClearREn,
							rocketDrawEn,
							gameOverEn,
							titlePageEn,
							drawEn,
							leftMoved,
							rightMoved, 
							inIntake, 
							yset);
							
	input clk, start, drewGameOver, hitEdge, command_left, command_right, reset, screenCleared, drewHomebase, rocketCleared, leftMoved, rightMoved;
	output reg rocketClearLEn, rocketClearREn, rocketDrawEn, leftEn, rightEn, screenClearEn, drawEn, gameOverEn, inIntake, yset, titlePageEn;

	reg [4:0] current_state, next_state;
	
	wire clickR, clickL;
	rate    #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) r (.clk(clk), .reset(reset), .Speed(2'b00), .Enable(clickR)); //can intake another input ever 0.5 s
	rate   #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) l (.clk(clk), .reset(reset), .Speed(2'b00), .Enable(clickL)); 
							
	localparam  TITLE_PAGE = 5'd0, 
				CLEAR_SCREEN = 5'd1,
				INTAKE = 5'd2,
				CLEAR_ROCKET_LEFT = 5'd3,
				CLEAR_ROCKET_RIGHT = 5'd4,
				MOVE_LEFT = 5'd5,
				LEFT_WAIT = 5'd6,
				MOVE_RIGHT = 5'd7,
				RIGHT_WAIT = 5'd8,
				GAME_OVER = 5'd9,
				DRAW_ROCKET = 5'd10,
				CLEAR_ROCKET_LEFT_DELAY = 5'd11,
				CLEAR_ROCKET_RIGHT_DELAY = 5'd12;
	
	//states for rocket control
	always@(*)
	begin: state_table
		case (current_state)
						TITLE_PAGE: next_state = start ? CLEAR_SCREEN : TITLE_PAGE;
						
						CLEAR_SCREEN: next_state = screenCleared ? DRAW_ROCKET : CLEAR_SCREEN;

						DRAW_ROCKET: next_state = drewHomebase ? INTAKE : DRAW_ROCKET;
								
						INTAKE: begin
								if (command_left) next_state = CLEAR_ROCKET_LEFT_DELAY;
								else if (command_right) next_state = CLEAR_ROCKET_RIGHT_DELAY;
								else next_state = INTAKE;
						end

						CLEAR_ROCKET_LEFT_DELAY: next_state = CLEAR_ROCKET_LEFT;
						CLEAR_ROCKET_RIGHT_DELAY: next_state = CLEAR_ROCKET_RIGHT;
						CLEAR_ROCKET_LEFT: next_state = rocketCleared ? MOVE_LEFT : CLEAR_ROCKET_LEFT;
						CLEAR_ROCKET_RIGHT: next_state = rocketCleared ? MOVE_RIGHT : CLEAR_ROCKET_RIGHT;

						MOVE_LEFT: begin 
							if(hitEdge) next_state = GAME_OVER;
							else if (leftMoved) next_state = LEFT_WAIT;
							else next_state = MOVE_LEFT;
						end

						MOVE_RIGHT: begin
							if(hitEdge) next_state = GAME_OVER;
							else if (rightMoved) next_state = RIGHT_WAIT;
							else next_state = MOVE_RIGHT;
						end	

						LEFT_WAIT: next_state = clickL ? INTAKE : INTAKE;
                              
						RIGHT_WAIT: next_state = clickR ? INTAKE : RIGHT_WAIT;
						
						GAME_OVER: next_state = drewGameOver ? TITLE_PAGE : GAME_OVER;			
			
		endcase
	end

	
	always @(*)
    begin: enable_signals
		screenClearEn = 1'b0;
		rocketClearLEn = 1'b0;
		rocketClearREn = 1'b0;
		rocketDrawEn = 1'b0;
		inIntake = 1'b0;
		titlePageEn = 1'b0;
		gameOverEn = 1'b0;
		leftEn = 1'b0;
		rightEn = 1'b0;
		drawEn = 1'b0;
		yset = 1'b0;
	
		case (current_state)
				TITLE_PAGE: begin drawEn = 1'b1; titlePageEn = 1'b1; end
				CLEAR_SCREEN: begin drawEn = 1'b1; screenClearEn = 1'b1;  end
				DRAW_ROCKET: begin drawEn = 1'b1; rocketDrawEn = 1'b1; end
				CLEAR_ROCKET_LEFT: begin drawEn = 1'b1; rocketClearLEn = 1'b1; end 
				CLEAR_ROCKET_LEFT_DELAY: yset = 1'b1; 
				CLEAR_ROCKET_RIGHT_DELAY: yset = 1'b1;
				CLEAR_ROCKET_RIGHT: begin drawEn = 1'b1; rocketClearREn = 1'b1; end
				INTAKE: inIntake = 1'b1;
				MOVE_RIGHT:
					begin 
						rightEn = 1'b1;
						drawEn = 1'b1;
					end
				MOVE_LEFT:
					begin 
						leftEn = 1'b1;
						drawEn = 1'b1;
					end
				GAME_OVER: begin drawEn = 1'b1;  gameOverEn = 1'b1; end

		endcase			
	end
										
	always @ (posedge clk)
	begin: reset_conditions
		if(~reset) 
			begin
				current_state <= TITLE_PAGE;
			end
			
		else
			begin
				current_state <= next_state;
			end
	end	
endmodule
