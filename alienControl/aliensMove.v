module aliensMove(input clk, reset, input [7:0]xin, input [6:0]yin, input clear1, clear2, clear3, clear4, clear5, moveDown, 
				output reg [7:0]xout, 
				output reg [6:0]yout, 
				output reg [2:0]colourOut,
				output reg cleared1, cleared2, cleared3, cleared4, cleared5);

parameter X_SCREEN_PIXELS = 8'd160;
parameter Y_SCREEN_PIXELS = 7'd120;
parameter xStart = 8'd10; //start of 11x10 square
parameter yStart = 7'd10;

reg [7:0] xorig = xin; //should start at here
reg [6:0] yorig = yin;
reg aliensCleared = 1'b0;
reg yIncremented = 1'b0;

reg [6:0] address = 6'b0;
wire [2:0] aliensColour;
assign wire clearAny = clear1 || clear2 || clear3 || clear4 || clear5;

aliens a0 (.address(address), .data(3'd000), .writeEn(clearAny), .colour(aliensColour))

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
				yIncremented = 1'b0;
			end
		if (clear1) //clear high stays high until done 
			begin 
				if (address < /**/)
					address <= address + 1
				else
					begin
						address <= 6'b0;
						cleared1 <= 1'b1;
						clearAny <= 1'b0;
					end

			end
		else if (clear2) //clear high stays high until done 
			begin 
				if (address <= /**/)
					address <= address + 1
				else
					begin
						address <= 6'b0;
						cleared2 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else if (clear3) //clear high stays high until done 
			begin 
				if (address <= /**/)
					address <= address + 1
				else
					begin
						address <= 6'b0;
						cleared3 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else if (clear4) //clear high stays high until done 
			begin 
				if (address <= /**/)
					address <= address + 1
				else
					begin
						address <= 6'b0;
						cleared4 <= 1'b1;
						clearAny <= 1'b0
					end
			end
		else if (clear5) //clear high stays high until done 
			begin 
				if (address <= /**/)
					address <= address + 1
				else
					begin
						address <= 6'b0;
						cleared5 <= 1'b1;
						clearAny <= 1'b0;
					end
			end
		else address <= address; //do nothing

		if (moveDown && ~ aliencCleared) //clear original
			if (yout < yorig + /*ADD VALUE FOR END OF COL + 1*/) 
				begin
					if (xout == xorig + /*end of row */)
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
					aliensCleared <= 1'b1;
					yout <= yorig;
				end
		if (aliensCleared && moveDown){ //draw row shift down - increment y by 5 then read memory addresses again
			if (!yIncremented)
				begin
					yorig <= yorig + 5;
					yout <= yout - 5;
					xout <= xorig;
					yIncremented = 1'b1;
				end
				
			//reow cleared - draw below 
			else if (yout < yorig + /*TODO*/) //CHANGE TO ACCOUNT FOR 114 EXTRA CYCLE IN yout?
				begin
					if (xout == xorig +/*TODO*/)
						begin
							xout <= xorig; //reset to original position
							yout <= yout + 1;
							colourOut <= shipColour;
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
					leftMoved <= 1'b1;
					address <= 7'b0;
					rocketCleared <= 1'b0;
				end
			//TODO - fix tmr 
			address <= address + 1;
			colourOut <= aliensColour;  
		}
	end


//reset clearAny to 0 once completed , set cleared to 1





endmodule
