//NEED TO TEST
module aliensFalling #(parameter CLOCK_FREQUENCY = 50000000)
							(input clk, input reset, input drewHomeBase, //drew homebase is our Enable for the rate divider 
							output drawEn, //drawEn set to 1 as soon as drewHomebase if ==1 and pass to the VGA 
							output gameOver, 
							output [5:0] CounterValue);
							
		wire enable
		RateDivider #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) alienFall (.clk(clk), .reset(drewHomeBase), .Speed(2'b11), .Enable(enable));
		DisplayCounterAlien u1 reset(reset(.clk(clk), .), .EnableDC(enable), .CounterValue(CounterValue), .gameOver(gameOver/*conects with gamover somewhere lol*/), .drawEn(drawEn)); 
		
		
endmodule

						 
/*--------------------------------------------------------------------------------------------------------*/						

 module rate #(parameter CLOCK_FREQUENCY = 5)
						(input clk, input reset, input [1:0] Speed,
							output Enable);

	reg [31:0] count;

	always @(posedge (clk))
		begin	
		
		if (~reset)	
				
				case (Speed)
				2'b00:  count = (CLOCK_FREQUENCY * 0.5)-1; //shot speed (3 pixels per second)
				2'b10:  count = (CLOCK_FREQUENCY / 3)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
				
			else if (Enable)
			
			case (Speed)
				2'b00:  count = (CLOCK_FREQUENCY * 0.5)-1; //shot speed (3 pixels per second)
				2'b10:  count = (CLOCK_FREQUENCY / 3)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
			
			else if (count > 0) 
			count<=count-1;
		
		
		end	
		assign Enable = (count == 32'b0)?'b1:'b0;		
							//output enable as soon as we count down to 0
				
							
endmodule






/*--------------------------------------------------------------------------------------------------------*/

//now need a display counter that will intake the enable signal and tell the VGA when to go down and when not to
	module DisplayCounterAlien (input clk, 
								input reset, 
								input EnableDC, 
								output [5:0] CounterValue
								output gameOver
								output drawEn);

		reg [5:0] display;

		always @(posedge (Reset), posedge (Clock))
			begin
		
			if (Reset)
				display <= 0;
				
				
			else if (EnableDC)
				if (display >= 6'b101000) //if the aliens have moved lower than 40
					 display <= 4'b0000;
					 gameover <= 1'b1;
					 drawEn <= 1'b0; // stop drawing
					 
				else
				
				display <= display +1;
				gameover <= 1'b0;
				drawEn <= 1'b1 //draw alien in new position
				
				
		end
	assign CounterValue = display;
	
endmodule

/*--------------------------------------------------------------------------------------------------------*/

/*--------------------------------------------------------------------------------------------------------*/
///WOULD NEED A DISPLAY COUNTER FOR THE SHOT
