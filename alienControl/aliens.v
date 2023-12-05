
//`include "a.v"
//`include "g.v"
//`include "yw.v"



module aliens #(parameter CLOCK_FREQUENCY=1)(clk, reset, xout, yout, colourOut, a_drawEn, shotXCoord, shotYCoord, score, collidedWithAlien);

input clk, reset;
input [7:0] shotXCoord;
input [6:0] shotYCoord;
output [7:0] xout;
output [6:0] yout;
output [2:0] colourOut;
output [2:0] score;
wire [2:0] scoreCount;
output a_drawEn; 
output collidedWithAlien;

wire kill1, kill2, kill3, kill4, kill5, moveDown, incremented;
wire cleared1, cleared2, cleared3, cleared4, cleared5, movedDown;
wire gameWon, gameDone, startRow, resetMove;

wire [7:0] xtop; 
wire [7:0] xbottom;
wire [6:0] ytop;
wire [6:0] ybottom;



aliensDatapath d1(.clk(clk), 
						.reset(reset),
						.gameWon(gameWon),
						.gameDone(gameDone),
						.xtop(xtop),
						.ytop(ytop), 
						.xbottom(xbottom), 
						.ybottom(ybottom), 
						.clear1(kill1), 
						.clear2(kill2), 
						.clear3(kill3), 
						.clear4(kill4), 
						.clear5(kill5), 
						.moveDown(moveDown), 
						.xout(xout), //for checngiing pixels on the screen
						.yout(yout), //on screen
						.colourOut(colourOut),
						.cleared1(cleared1),
						.cleared2(cleared2), 
						.cleared3(cleared3), 
						.cleared4(cleared4), 
						.cleared5(cleared5), 
						.movedDown(movedDown), 
						.clearAny(collidedWithAlien),
						.startRow(startRow),
						.scoreCount(scoreCount),
						.score(score),
						.incremented(incremented),
						.resetMove(resetMove));


alienTalentManager #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) c1 (.clk(clk), 
									.reset(reset), 
									.shotXcoord(shotXCoord), 
									.shotYcoord(shotYCoord), 
									.gameOver(gameDone),
									.youWin(gameWon), 
									.kill1(kill1),
									.kill2(kill2), 
									.kill3(kill3), 
									.kill4(kill4),
									.kill5(kill5), 
									.drawEn(a_drawEn),
									.moveDown(moveDown),
									.clearedShift (movedDown), 
									.cleared1(cleared1),
									.cleared2(cleared2),
									.cleared3(cleared3), 
									.cleared4(cleared4), 
									.cleared5(cleared5),
									.alienTopY(ytop), 
									.alienTopX(xtop), 
									.alienBottomX(xbottom), 
									.alienBottomY(ybottom),
									.startRow(startRow),
									.scoreCount(scoreCount),
									.incremented(incremented),
									.resetMove(resetMove));


endmodule



module aliensDatapath(input clk, input reset, input gameWon, input resetMove, input gameDone, input [7:0]xtop, input [6:0]ytop, input [7:0]xbottom, input [6:0]ybottom, input clear1, clear2, clear3, clear4, clear5, moveDown, 
				output reg [7:0]xout, //for checngiing pixels on the screen
				output reg [6:0]yout, //on screen
				output reg [2:0]colourOut,
				output reg incremented,
				output reg [2:0] scoreCount,
				output reg [2:0] score,
				output reg cleared1, cleared2, cleared3, cleared4, cleared5, movedDown, clearAny, startRow);

parameter X_SCREEN_PIXELS = 8'd160;
parameter Y_SCREEN_PIXELS = 7'd120;
parameter xStart = 8'd10; //start of 11x10 square
parameter yStart = 7'd10;


//reg [7:0] xorig; //= xStart; should start at here
//reg [6:0] yorig; //= yStart;
reg aliensCleared = 1'b0;
reg yIncremented = 1'b0;
reg last, current;
wire positiveany;
reg [7:0] xorig = xStart;
reg [6:0] yorig = yStart;
reg [10:0] address = 11'b0;
wire [2:0] aliensColour, gameOverColour, youWinColour;
reg clear1set, clear2set, clear3set, clear4set, clear5set;



reg [14:0]addressFS = 15'b0;

//check alienRow instantiation

a a0 (.clock(clk), .address(address), .data(3'd000), .wren(clearAny), .q(aliensColour));
g g0 (.clock(clk), .address(addressFS), .q(gameOverColour)); //has game over mif
yw w0 (.clock(clk), .address(addressFS), .q(youWinColour)); //has you win mif



//at moveDown, decrement y and cycle through all xy in the block

		always @(posedge clk)
		begin
			last <= current;
			current <= clearAny;

		end

		assign positiveany = (current == 1'b1 && last ==1'b0);

			

always@(posedge clk)
	begin
		if (~reset) //if one of the clears is high, replace PERTINENT memory addresses with 000
			begin
				xout <= 8'd254;
				yout <= yStart;
				cleared1 <= 1'b0; 
				cleared2 <= 1'b0; 
				cleared3 <= 1'b0;
				cleared4 <= 1'b0;
				cleared5 <= 1'b0;
				scoreCount <= 3'b0;
				score<= 3'b0;
				clearAny <= 1'b0;
				startRow <= 1'b0;
            clear1set <= 1'b0;
            clear2set <= 1'b0;
            clear3set <= 1'b0;
            clear4set <= 1'b0;
            clear5set <= 1'b0;
				yIncremented = 1'b0;
				movedDown <= 1'b0;
				colourOut <= 3'b0;
				incremented <= 1'b1;
			end

		if (~startRow) begin //draw initial row of aliens

			if (yout < (yStart + 7'd10)) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original position
							yout <= yout + 1;
							address <= address + 1;	
							colourOut <= aliensColour;
							
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= aliensColour;
							address <= address + 1; 
							
						end
				end

			else
				begin
					address <= 11'b0;
					
					startRow <= 1'b1;
				end
		end 

			if (positiveany)
				begin
				scoreCount  <= scoreCount +1;
				score <= score +1;
				end
				

		if (clear1) //clear high stays high until done - use assign statements outside always block to originally set 
            begin
				if (!clear1set)

				begin
					yout <= ytop; 
					xout <= xtop;
					address <= 7'd9; //check this right start position
					clear1set <= 1'b1;
					clearAny <= 1'b1;

				end  


             if (yout < (ybottom + 1))  //this will take in y coord from FSM 
						begin
							if (xout == xbottom)
								begin
									
									address <= address + 11'd149;
									colourOut <= 3'b0;


										if (yout < (ybottom + 1)) 
											begin yout <= yout + 1; 
													xout <= xtop; //reset to original
													address <= address + 11'd149; // change
													clearAny <= 1'b1;

											end		
								end

							else 
								begin
									xout <= xout + 1;
									colourOut <= 3'b0;
									clearAny <= 1'b1;
									address <= address + 1;

								end
						end

			if (xout == xbottom && yout == ybottom) begin cleared1 <= 1'b1; clearAny <= 1'b0; end
			end


		else if (clear2) //clear high stays high until done 
		begin
            if (!clear2set)
				begin
					yout <= ytop;
					xout <= xtop;
					clear2set <= 1'b1;
					clearAny <= 1'b1;
				
					address <= 11'h2a; //FIRST ADDRESS

				end

            if (yout < (ybottom+1))  //clear
					begin
					
					if (xout == xbottom) //8'd53
						begin
							xout <= 8'd42; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
							address <= address + 11'd149;
						end
						
						
						if (xout == xbottom)
								begin
									
									address <= address + 11'd149;
									colourOut <= 3'b0;


										if (yout < (ybottom + 1)) 
											begin yout <= yout + 1; 
													xout <= xtop; //reset to original
													address <= address + 11'd149; // change
													clearAny <= 1'b1;

											end		
								end
								
								

					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
							clearAny <= 1'b1;
							address <= address + 1;
							
						end
					end
			if (xout == xbottom && yout == ybottom) begin cleared2 <= 1'b1; clearAny <= 1'b0; end

			end
			
			
		else if (clear3) //clear high stays high until done 
		begin
			if (!clear3set)
				begin
					yout <= ytop; 
					xout <= xtop;
					clear3set <= 1'b1;
					address <= 11'h4a;
				end

            begin 
            if (yout < (ybottom+1))  //clear
				begin
					if (xout == xbottom)
					
						begin
							xout <= xtop; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
							address <= address + 11'd149;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
							clearAny <= 1'b1;
							address <= address + 1;
						end

				end

			if (xout == xbottom && yout == ybottom) begin cleared3 <= 1'b1; clearAny <= 1'b0; end

			end
			end
		else if (clear4) //clear high stays high until done 
			begin
			if (!clear4set)
				begin
					yout <= ytop; 
					xout <= xtop;
					clear4set <= 1'b1;
					address <= 11'h6a;
					
				end

            begin 

                if (yout < (ybottom+1))  //clear
				begin
					if (xout == xbottom)
						begin
							xout <= xtop; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
							address <= address + 11'd149;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
							clearAny <= 1'b1;
							address <= address + 1;
							// address <= 11'd1059;
						end

				end


				// begin
				// if (address <= 11'd1180)
				// 	address <= address + 1;
				// else
				// 	begin
				// 		address <= 11'b0;
				// 		cleared4 <= 1'b1;
				// 		clearAny <= 1'b0;
				// 		aliensMoveEn <= 1'b0;
				// 	end
				// end
			if (xout == xbottom && yout == ybottom) begin cleared4 <= 1'b1; clearAny <= 1'b0; end

			end
			end
		else if (clear5) //clear high stays high until done 
		begin
			if (!clear5set)
				begin
					yout <= ytop; 
					xout <= xtop;
					clear5set <= 1'b1;
					
					address <= 1'h8a;
				end


            begin 

                if (yout < (ybottom+1))  //clear
				begin
					if (xout == xbottom)
						begin
							xout <= xtop; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
							address <= address + 11'd149;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
							clearAny <= 1'b1;
							// address <= 11'd1379;
							address <= address + 1;
						end
				end

				if (xout == xbottom && yout == ybottom) begin cleared5 <= 1'b1; clearAny <= 1'b0; end

			end
			end


		begin
		if (moveDown && ~aliensCleared) //clear original
		begin
			if (yout < (yorig + 7'd10)) 
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
							
						end
					else
						begin
							xout <= xout + 8'b1;
							colourOut <= 3'b0;
					
						end
				end

			else 
				begin
					aliensCleared = 1'b1;
					yout <= yorig;
				
				end
			end
		end 

		if (aliensCleared && moveDown) begin //draw row shift down - increment y by 5 then read memory addresses again
			if (!yIncremented)
				begin
					yorig <= yorig + 7'd5;
					yout <= yorig + 7'd5;
					xout <= 8'd0;
					yIncremented = 1'b1;
				
				end

			//row cleared - draw alien row below 
			else if (yout < yorig + 7'd10) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original position
							yout <= yout + 7'b1;
							colourOut <= aliensColour;
							address <= address + 15'b1;	
						end
					else
						begin
							xout <= xout + 8'b1;
							colourOut <= aliensColour;
							address <= address + 15'b1; 
						end
				end

			else
				begin
					movedDown <= 1'b1;
					address <= 11'b0;
				
					aliensCleared = 1'b0; //this necessary
					yIncremented = 1'b0;
				end
		end

	if (resetMove) begin movedDown <= 1'b0; end

	if (gameDone)
		begin 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= 7'd0;
					addressFS <= 15'b0;
					
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
                     colourOut <= gameOverColour;
							
						end
					else
						begin
							colourOut <= gameOverColour; 
							xout <= xout + 1;
							addressFS <= addressFS + 1;
						end
				end
		end

	if (gameWon)
		begin 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= 7'd0;
					addressFS <= 15'b0;
				
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
                     colourOut <= youWinColour;
					
						end
					else
						begin
							colourOut <= youWinColour; 
							xout <= xout + 1;
							addressFS <= addressFS + 1;
						end
				end
	end
	
	
	
	
end

//reset clearAny to 0 once completed , set cleared to 1

endmodule


/*-----------------------------------------------------------------CONTROLPATH------------------------------------------------------------------------------------------*/



module alienTalentManager #(parameter CLOCK_FREQUENCY)
									(clk, reset, shotXcoord, shotYcoord, gameOver,
									youWin, scoreCount, 
									kill1, kill2, kill3, kill4, kill5, moveDown,
									clearedShift, cleared1, cleared2, cleared3, cleared4, cleared5,
									alienTopY, alienTopX, alienBottomX, alienBottomY, startRow, incremented, drawEn, resetMove); //needs to take care of the collidedWithAlien for the shots control
	//FUNCTIONALITY:
	
	//update position when need to mode down
	//send out clear signals when an alien has been hit
	
	input clk, reset, clearedShift, cleared1, cleared2, cleared3, cleared4, cleared5, startRow, incremented;
	input [7:0] shotXcoord;
	input [6:0] shotYcoord;
	input [2:0] scoreCount;
	output reg [7:0]  alienTopX, alienBottomX; 
	output reg [6:0]  alienTopY, alienBottomY;
	output reg gameOver, youWin, kill1, kill2, kill3, kill4, kill5, moveDown, drawEn, resetMove;
	

	parameter width = 8'd11;
	parameter height = 7'd9;
	parameter gap = 8'd19;
	parameter startX = 8'd10;
	parameter startY = 7'd10;
	
	
	reg [3:0] current_state, next_state;
	reg[4:0] dropCounter; // if goes to 18 -> gameOver
	wire drop;
	reg [6:0] currentYTop = startY;  //gets incremented after every drop
	reg killed1, killed2, killed3, killed4, killed5;
	
	
	//instantiate rate Divider for Alien drop
	rate #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) alienDrop (.clk(clk), .reset(reset), .Speed(2'b11), .Enable(drop));
	
	
	
	localparam
	
		FIRST_POSITION = 4'd0,
		INTAKE = 4'd1,
		DROP_ALIEN = 4'd2,
		INCREMENT_DROP_ALIEN = 4'd3,
		KILL_ONE = 4'd4,
		KILL_TWO= 4'd5,
		KILL_THREE = 4'd6,
		KILL_FOUR = 4'd7,
		KILL_FIVE = 4'd8,
		LOSE_GAME = 4'd9,
		WIN_GAME = 4'd10;
		
		
		always @(*)
		
			begin: state_table
				case (current_state)
				
				FIRST_POSITION: next_state = (startRow) ? INTAKE : FIRST_POSITION;
				
				INTAKE: begin 
		
								if(drop) begin
								next_state = DROP_ALIEN;
								end
								
	
								else if ((shotYcoord <= (currentYTop + height)) && (shotXcoord >= startX) && 
											(shotXcoord <= startX + width) && (~killed1))
										begin
										
										next_state = KILL_ONE;
										
										
										end
								
								else if ((shotYcoord <= (currentYTop + height)) && (shotXcoord >= (startX + width + gap)) && 
											(shotXcoord <= (startX + width + width + gap))&& (~killed2))
										begin
										
										next_state = KILL_TWO;
										
										
								
								end else if ((shotYcoord <= (currentYTop + height)) && (shotXcoord >= (startX + width + gap+ width + gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width))&& (~killed3)) begin
										
										next_state = KILL_THREE;
										
								end else if((shotYcoord <= (currentYTop + height)) && (shotXcoord >= (startX + width + gap+ width + gap + width +gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width +gap +width))&& (~killed4)) begin
										
										
										next_state = KILL_FOUR;
										
													
								end else if((shotYcoord <= (currentYTop + height)) && (shotXcoord >= (startX + width + gap+ width + gap + width +gap + width +gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width +gap + width +gap +width))&& (~killed5))begin
											
										next_state = KILL_FIVE;
										
										end
										
								else if (scoreCount == 3'd5)
										begin
										
										next_state = WIN_GAME;	
										
										end
							
								else if (dropCounter == 5'd18) 
										begin
											
										next_state = LOSE_GAME;
											
										end
										
							else next_state = INTAKE;
										
						  end
				DROP_ALIEN: next_state = (clearedShift) ? INCREMENT_DROP_ALIEN : DROP_ALIEN ;
				INCREMENT_DROP_ALIEN: next_state = (incremented) ? INTAKE : INCREMENT_DROP_ALIEN ;
				KILL_ONE: next_state = (cleared1) ? INTAKE: KILL_ONE;
				KILL_TWO: next_state = (cleared2) ? INTAKE: KILL_TWO;
				
				KILL_THREE: next_state = (cleared3) ? INTAKE: KILL_THREE;
			
				KILL_FOUR:  next_state =  (cleared4) ? INTAKE: KILL_FOUR;
	
				KILL_FIVE:  next_state =  (cleared5) ? INTAKE: KILL_FIVE;
				
				LOSE_GAME: next_state = LOSE_GAME; 
				WIN_GAME: next_state = WIN_GAME;
				
			default: next_state = INTAKE;
			endcase
		end
		
	
	always@(posedge clk)
		begin: state_transition
		if (~reset)
		
		begin
			dropCounter <= 5'b0;
			currentYTop <= 7'd10;
			current_state <= FIRST_POSITION;
			killed1 <=1'b0; 
			killed2 <= 1'b0;
			killed3 <= 1'b0;
			killed4 <= 1'b0;
			killed5 <= 1'b0;
			drawEn <= 1'b0;
			resetMove <= 1'b0;

			
		end	
		else current_state <= next_state;
		
				alienTopX <= 8'd0;
				alienBottomX <= 8'd0;
				alienTopY <= 7'd0;
				alienBottomY <= 7'd0;
				gameOver <= 1'b0;
				youWin <= 1'b0; 
				kill1 <= 1'b0; 
				kill2 <= 1'b0; 
				kill3 <= 1'b0; 
				kill4 <= 1'b0; 
				kill5 <= 1'b0;
				moveDown <= 1'b0;
				resetMove <= 1'b0;
				drawEn <= 1'b0;
				
				
				
			case (current_state)
			INTAKE: drawEn <= 1'b0;

			DROP_ALIEN: begin moveDown <= 1'b1; drawEn <= 1'b1; end
			
			INCREMENT_DROP_ALIEN: begin resetMove <=1'b1; dropCounter <= dropCounter + 1; currentYTop <= currentYTop +5; end
		
			KILL_ONE: 
					begin kill1 <= 1'b1; 
							alienTopX <= (startX); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width);
							alienBottomY <= (startY+currentYTop + height);
							killed1 <=1'b1; 
							drawEn <= 1'b1;
						
					end
					
		
			
			KILL_TWO : 
					begin kill2 <= 1'b1; 
							alienTopX <= (startX + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap +width);
							alienBottomY <= (startY+currentYTop + height);
							killed2 <=1'b1; 
							drawEn <= 1'b1;
		
					end	

			
			KILL_THREE: begin 
							kill3 <= 1'b1; 
							alienTopX <= (startX + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							killed3 <=1'b1;
							drawEn <= 1'b1;	
						
							end

			
			KILL_FOUR: 	begin
							kill4 <= 1'b1; 
							alienTopX <= (startX + width +gap + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							killed4 <=1'b1; 
							drawEn <= 1'b1;
				
							end
							

			
			KILL_FIVE: begin
							kill5 <= 1'b1; 
							alienTopX <= (startX + width +gap + width + gap + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width + gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							killed5 <=1'b1;
							drawEn <= 1'b1;	
							end
			

			LOSE_GAME: begin gameOver <= 1'b1; drawEn <= 1'b1; end
			WIN_GAME: begin youWin <= 1'b1; drawEn <= 1'b1; end
		
			endcase	
	
	end

		
endmodule

