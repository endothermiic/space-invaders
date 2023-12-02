module aliensMove(input clk, reset, input [7:0]xtop, input [6:0]ytop, input [7:0]xbottom, input [6:0]ybottom, input clear1, clear2, clear3, clear4, clear5, moveDown, 
				output reg [7:0]xout, 
				output reg [6:0]yout, 
				output reg [2:0]colourOut,
				output reg aliensMoveEn,
				output reg cleared1, cleared2, cleared3, cleared4, cleared5, movedDown);

parameter X_SCREEN_PIXELS = 8'd160;
parameter Y_SCREEN_PIXELS = 7'd120;
parameter xStart = 8'd10; //start of 11x10 square
parameter yStart = 7'd10;

reg [7:0] xorig = xStart; //should start at here
reg [6:0] yorig = yStart;
reg aliensCleared = 1'b0;
reg yIncremented = 1'b0;

reg [10:0] address = 11'b0;
wire [2:0] aliensColour, gameOverColour, youWinColour;
assign wire clearAny = clear1 || clear2 || clear3 || clear4 || clear 5;
reg startRow, clear1set, clear2set, clear3set, clear4set, clear5set;
reg gameWon, gameDone;

reg [14:0]addressFS = 15'b0;

//check alienRow instantiation

alienRow a0 (.address(address), .data(3'd000), .writeEn(clearAny), .qr(aliensColour));
gameOver g0 (.clock(clk), .address(addressFS), .q(gameOverColour)); //has game over mif
youWin w0 (.clock(clk), .address(addressFS), .q(youWinColour)); //has you win mif


//at moveDown, decrement y and cycle through all xy in the block
always@(posedge clk)
	begin
		if (reset) //if one of the clears is high, replace PERTINENT memory addresses with 000
			begin
				xout <= 7'b0;
				yout <= 6'b0;
				cleared1 <= 1'b0; 
				cleared2 <= 1'b0; 
				cleared3 <= 1'b0;
				cleared4 <= 1'b0;
				cleared5 <= 1'b0;
                clear1set <= 1'b0;
                clear2set <= 1'b0;
                clear3set <= 1'b0;
                clear4set <= 1'b0;
                clear5set <= 1'b0;
				yIncremented = 1'b0;
				movedDown <= 1'b0;
				aliensMoveEn <= 1'b0;
			end
		if (~startRow) begin //draw initial row of aliens
			if (yout < yStart + 7'd10) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original position
							yout <= yout + 1;
							colourOut <= aliensColour;
							address <= address + 1;	
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
					startRow <= 1'b1;
					address <= 7'b0;
					aliensMoveEn <= 1'b1;
				end
		end 

		if (clear1) //clear high stays high until done - use assign statements outside always block to originally set 
            if (!clear1set)
				begin
					yout <= 7'd10;
					xout <= 7'd10;
					clear1set = 1'b1;
				end  
            begin 
                if (yout < 7'd21)  //clear
				begin
					if (xout == 8'd22)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
						end
				end
            
                //write to memory
				if (address < 11'd220) //TODO / CHECK
					address <= address + 1;
				else
					begin
						address <= 11'b0;
						cleared1 <= 1'b1;
						clearAny <= 1'b0;
					end

			end
		else if (clear2) //clear high stays high until done 
            if (!clear2set)
				begin
					yout <= 7'd10;
					xout <= 7'd43;
					clear2set = 1'b1;
				end
			begin 
                if (yout < 7'd21)  //clear
				begin
					if (xout == 8'd54)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
						end
				end


				if (address < 11'd540)
					address <= address + 1
				else
					begin
						address <= 11'b0;
						cleared2 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else if (clear3) //clear high stays high until done 
			if (!clear3set)
				begin
					yout <= 7'd10;
					xout <= 7'd75;
					clear3set = 1'b1;
				end
            begin 
                if (yout < 7'd21)  //clear
				begin
					if (xout == 8'd86)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
						end
				end


				if (address < 11'd860)
					address <= address + 1
				else
					begin
						address <= 11'b0;
						cleared3 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else if (clear4) //clear high stays high until done 
			if (!clear4set)
				begin
					yout <= 7'd10;
					xout <= 7'd107;
					clear4set = 1'b1;
				end
            
            begin 

                if (yout < 7'd21)  //clear
				begin
					if (xout == 8'd118)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
						end
				end




				if (address <= 11'd1180)
					address <= address + 1
				else
					begin
						address <= 11'b0;
						cleared4 <= 1'b1;
						clearAny <= 1'b0
					end
			end
		else if (clear5) //clear high stays high until done 
			if (!clear5set)
				begin
					yout <= 7'd10;
					xout <= 7'd139;
					clear5set = 1'b1;
				end
            
            
            begin 

                if (yout < 7'd150)  //clear
				begin
					if (xout == 8'd86)
						begin
							xout <= 8'd0; //reset to original
							yout <= yout + 1;
							colourOut <= 3'b0;
						end
					else
						begin
							xout <= xout + 1;
							colourOut <= 3'b0;
						end
				end

				if (address < 11'd1500)
					address <= address + 1
				else
					begin
						address <= 11'b0;
						cleared5 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else address <= address; //do nothing

		if (moveDown && ~aliensCleared) //clear original
			if (yout < yorig + 7'd10) 
				begin
					if (xout == 8'd159)
						begin
							xout <= 8'd0; //reset to original
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
					aliensCleared <= 1'b1;
					yout <= yorig;
				end
		if (aliensCleared && moveDown) begin //draw row shift down - increment y by 5 then read memory addresses again
			if (!yIncremented)
				begin
					yorig <= yorig + 5;
					yout <= yorig + 5;
					xout <= 8'd0;
					yIncremented = 1'b1;
				end
				
			//row cleared - draw alien row below 
			else if (yout < yorig + 7'd11) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == 8'd159)
						begin
							xout <= xorig; //reset to original position
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
				end
		end
	end


	if (gameOver)
		begin 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= 8'd0; 
					yout <= yorig;
					gameDone <= 1'b1;
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

	if (youWin)
		begin 
			if (xout == X_SCREEN_PIXELS - 1 && yout == Y_SCREEN_PIXELS - 1) 
				begin
					xout <= xorig; 
					yout <= yorig;
					gameWon <= 1'b1;
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


//reset clearAny to 0 once completed , set cleared to 1

endmodule
