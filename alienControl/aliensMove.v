`include "gameovernew.v"
`include "alienrow.v"
`include "youWin.v"




module aliensDatapath(input clk, reset, input [7:0]xtop, input [6:0]ytop, input [7:0]xbottom, input [6:0]ybottom, input clear1, clear2, clear3, clear4, clear5, moveDown, 
				output reg [7:0]xout, 
				output reg [6:0]yout, 
				output reg [2:0]colourOut,
				output reg aliensMoveEn,
				output reg cleared1, cleared2, cleared3, cleared4, cleared5, movedDown, clearAny);

parameter X_SCREEN_PIXELS = 8'd160;
parameter Y_SCREEN_PIXELS = 7'd120;
parameter xStart = 8'd10; //start of 11x10 square
parameter yStart = 7'd10;
parameter ALIEN1_X = 8'd10;
parameter ALIEN1_Y = 7'd10;

reg [7:0] xorig = xStart; //should start at here
reg [6:0] yorig = yStart;
reg aliensCleared = 1'b0;
reg yIncremented = 1'b0;

reg [10:0] address = 11'b0;
wire [2:0] aliensColour, gameOverColour, youWinColour;
reg startRow, clear1set, clear2set, clear3set, clear4set, clear5set;
reg gameWon, gameDone;

reg [14:0]addressFS = 15'b0;

//check alienRow instantiation

ar a0 (.clock(clk), .address(address), .data(3'd000), .wren(clearAny), .q(aliensColour));
g g0 (.clock(clk), .address(addressFS), .q(gameOverColour)); //has game over mif
yw w0 (.clock(clk), .address(addressFS), .q(youWinColour)); //has you win mif


//at moveDown, decrement y and cycle through all xy in the block
always@(posedge clk)
	begin
		if (~reset) //if one of the clears is high, replace PERTINENT memory addresses with 000
			begin
				xout <= 7'b0;
				yout <= yStart;
				cleared1 <= 1'b0; 
				cleared2 <= 1'b0; 
				cleared3 <= 1'b0;
				cleared4 <= 1'b0;
				cleared5 <= 1'b0;
				gameWon <= 1'b0;
				gameDone <= 1'b0;
				clearAny <= 1'b0;
				startRow <= 1'b0;
                clear1set <= 1'b0;
                clear2set <= 1'b0;
                clear3set <= 1'b0;
                clear4set <= 1'b0;
                clear5set <= 1'b0;
				yIncremented = 1'b0;
				movedDown <= 1'b0;
				aliensMoveEn <= 1'b0;
				colourOut <= 3'b0;
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
							aliensMoveEn <= 1'b1;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= aliensColour;
							address <= address + 1; 
							aliensMoveEn <= 1'b1;
						end
				end
				
			else
				begin
					startRow <= 1'b1; //mbe come back
					address <= 11'b0;
					aliensMoveEn <= 1'b0;
					yout <= yorig;
				end
		end 

		if (clear1) //clear high stays high until done - use assign statements outside always block to originally set 
            begin
				if (!clear1set)
				begin
					yout <= ALIEN1_Y; 
					xout <= ALIEN1_X;
					address <= 11'd10; //check this right start position
					clear1set <= 1'b1;
					aliensMoveEn <= 1'b1;
					clearAny <= 1'b1;
					
				end  

			
             if (yout < (ALIEN1_Y + 7'd10))  //this will usually take in y coord from FSM - test 1st for testing
						begin
							if (xout == ALIEN1_X + 8'd11)
								begin
									xout <= ALIEN1_X; //reset to original
										if (yout < (yorig + 7'd10)) begin yout <= yout + 1; end
										
									colourOut <= 3'b0;
									clearAny <= 1'b1;
									address <= address + 11'd149; // change
								end
							else
								begin
									xout <= xout + 1;
									colourOut <= 3'b0;
									clearAny <= 1'b1;
									address <= address + 1;
								end
						end
					else
						begin
						cleared1 <= 1'b1;
						clearAny <= 1'b0;
						aliensMoveEn <= 1'b0;
						end
		
			end

//TODO
				// begin
				// if (address < 11'd540)
				// 	address <= address + 1;
				// else
				// 	begin
				// 		address <= 11'b0;
				// 		cleared2 <= 1'b1;
				// 		clearAny <= 1'b0;
				// 		aliensMoveEn <= 1'b0;
				// 	end
				// end

				
		
		else if (clear2) //clear high stays high until done 
		begin
            if (!clear2set)
				begin
					yout <= 7'd10;
					xout <= 7'd42;
					clear2set <= 1'b1;
					clearAny <= 1'b1;
					aliensMoveEn <= 1'b1;
					address <= 11'h2a; //FIRST ADDRESS
				end

            if (yout < (ALIEN1_Y + 7'd10))  //clear
					begin
					if (xout == 8'd53)
						begin
							xout <= 8'd42; //reset to original
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

				// begin
				// if (address < 11'd540)
				// 	address <= address + 1;
				// else
				// 	begin
				// 		address <= 11'b0;
				// 		cleared2 <= 1'b1;
				// 		clearAny <= 1'b0;
				// 		aliensMoveEn <= 1'b0;
				// 	end
				// end
				
			end
		else if (clear3) //clear high stays high until done 
		begin
			if (!clear3set)
				begin
					yout <= 7'd10;
					xout <= 7'd74;
					clear3set <= 1'b1;
					aliensMoveEn <= 1'b1;
					address <= 11'h4a;
				end
				
            begin 
            if (yout < (ALIEN1_Y + 7'd10))  //clear
				begin
					if (xout == 8'd85)
						begin
							xout <= 8'd74; //reset to original
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

			
				// begin
				// if (address < 11'd860)
				// 	address <= address + 1;
				// else
				// 	begin
				// 		address <= 11'b0;
				// 		cleared3 <= 1'b1;
				// 		clearAny <= 1'b0;
				// 		aliensMoveEn <= 1'b0;
				// 	end
				// end	
					
			end
			end
		else if (clear4) //clear high stays high until done 
			begin
			if (!clear4set)
				begin
					yout <= 7'd10;
					xout <= 7'd106;
					clear4set <= 1'b1;
					address <= 11'h6a;
					aliensMoveEn <= 1'b1;
				end
            
            begin 

                if (yout < (ALIEN1_Y + 7'd10))  //clear
				begin
					if (xout == 8'd117)
						begin
							xout <= 8'd106; //reset to original
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
				
			end
			end
		else if (clear5) //clear high stays high until done 
		begin
			if (!clear5set)
				begin
					yout <= 7'd10; //reset these as well
					xout <= 7'd138;
					clear5set <= 1'b1;
					aliensMoveEn <= 1'b1;
					address <= 1'h8a;
				end
            
            
            begin 

                if (yout < (ALIEN1_Y + 7'd10))  //clear
				begin
					if (xout == 8'd149)
						begin
							xout <= 8'd138; //reset to original
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

				// begin
				// if (address < 11'd1500)
				// 	address <= address + 1;
				// else
				// 	begin
				// 		address <= 11'b0;
				// 		cleared5 <= 1'b1;
				// 		clearAny <= 1'b0;
				// 		aliensMoveEn <= 1'b0;
				// 	end
				// end
					
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
							aliensMoveEn <= 1'b1;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
							aliensMoveEn <= 1'b1;
						end
				end
			
			else 
				begin
					aliensCleared = 1'b1;
					yout <= yorig;
					aliensMoveEn <= 1'b0;
				end
			end
		end 
		
		if (aliensCleared && moveDown) begin //draw row shift down - increment y by 5 then read memory addresses again
			if (!yIncremented)
				begin
					yorig <= yorig + 5;
					yout <= yorig + 5;
					xout <= 8'd0;
					yIncremented = 1'b1;
					aliensMoveEn <= 1'b1;
				end
				
			//row cleared - draw alien row below 
			else if (yout < yorig + 7'd10) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original position
							yout <= yout + 1;
							colourOut <= aliensColour;
							address <= address + 1;	
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
					movedDown <= 1'b1;
					address <= 11'b0;
					aliensMoveEn <= 1'b0;
					aliensCleared = 1'b0; //this necessary
					yIncremented = 1'b0;
				end
		end



	if (gameDone)
		begin 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= 7'd0;
					gameDone <= 1'b1;
					addressFS <= 15'b0;
					aliensMoveEn <= 1'b0;
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
                     colourOut <= gameOverColour;
							aliensMoveEn <= 1'b1;
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
					gameWon <= 1'b1;
					addressFS <= 15'b0;
					aliensMoveEn <= 1'b0;	
				end
			else
				begin
					if (xout == 8'd159)
						begin 
							xout <= 8'b0;
							yout <= yout + 1;
							addressFS <= addressFS + 1;
                     colourOut <= youWinColour;
							aliensMoveEn <= 1'b1;
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
