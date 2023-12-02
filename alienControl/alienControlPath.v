//NEED TO HOOK UP ONE MORE STATE FOR DEFAULT DRAW
//POTENTIALLY - add score count check stages after every kill. yeah... prob neeed that

module alienTalentManager #(parameter CLOCK_FREQUENCY = 5)
									(clk, reset, shotXcoord, shotYcoord, gameOver,
									youWin, scoreCount, 
									kill1, kill2, kill3, kill4, kill5, moveDown,
									clearedShift, cleared1, cleared2, cleared3, cleared4, cleared5,
									alienTopY, alienTopX, alienBottomX, alienBottomY); //needs to take care of the collidedWithAlien for the shots control
	//FUNCTIONALITY:
	
	//update position when need to mode down
	//send out clear signals when an alien has been hit
	
	input clk, reset, clearedShift, cleared1, cleared2, cleared3, cleared4, cleared5;
	input [7:0] shotXcoord;
	input [6:0] shotYcoord;
	output reg [7:0]  alienTopX, alienBottomX; 
	output reg [6:0]  alienTopY, alienBottomY;
	output reg [2:0] 	scoreCount;
	output reg gameOver, youWin, kill1, kill2, kill3, kill4, kill5, moveDown;
	
	parameter width = 8'd12;
	parameter height = 7'd10;
	parameter gap = 8'd20;
	parameter startX = 8'd10;
	parameter startY = 7'd10;
	
	
	reg [3:0] current_state, next_state;
	reg[5:0] dropCounter; // if goes to 40 -> gameOver
	wire drop;
	reg [6:0] currentYTop = startY; //gets incremented after every drop
	
	
	//instantiate rate Divider for Alien drop
	rate #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) alienDrop (.clk(clk), .reset(reset), .Speed(2'b11), .Enable(drop));
	
	
	
	localparam
	
		INTAKE = 4'd0,
		DROP_ALIEN = 4'd1,
		WAIT_DROP_ALIEN = 4'd2,
		KILL_ONE = 4'd3,
		WAIT_CLEAR_ONE = 4'd4,
		KILL_TWO= 4'd5,
		WAIT_CLEAR_TWO = 4'd6,
		KILL_THREE = 4'd7,
		WAIT_CLEAR_THREE = 4'd8,
		KILL_FOUR = 4'd9,
		WAIT_CLEAR_FOUR = 4'd10,
		KILL_FIVE = 4'd11,
		WAIT_CLEAR_FIVE = 4'd12,
		LOSE_GAME = 4'd13,
		WIN_GAME = 4'd14;
		
		
		always @(*)
		
			begin: state_table
				case (current_state)
				
				INTAKE: begin 
								if(drop) begin
								next_state = DROP_ALIEN;
								end
								
								else if ((shotYcoord == (currentYTop - height)) && (shotXcoord >= startX) && 
											(shotXcoord <= startX + width))
										begin
										
										next_state = KILL_ONE;
										
										end
								
								else if ((shotYcoord == (currentYTop - height)) && (shotXcoord >= (startX + width + gap)) && 
											(shotXcoord <= (startX + width + width + gap)))
										begin
										
										next_state = KILL_TWO;
										
										
								
								end else if ((shotYcoord == (currentYTop - height)) && (shotXcoord >= (startX + width + gap+ width + gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width))) begin
										
										next_state = KILL_THREE;
										
								end else if((shotYcoord == (currentYTop - height)) && (shotXcoord >= (startX + width + gap+ width + gap + width +gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width +gap +width))) begin
										
										
										next_state = KILL_FOUR;
										
													
								end else if((shotYcoord == (currentYTop - height)) && (shotXcoord >= (startX + width + gap+ width + gap + width +gap + width +gap)) && 
											(shotXcoord <= (startX + width + gap+ width + gap + width +gap + width +gap +width)))begin
											
										next_state = KILL_FOUR;
										
										end
							
								else if (dropCounter == 6'd40) 
										begin
											
										next_state = LOSE_GAME;
											
										end
										
								else if (scoreCount == 2'd5)
										begin
										
										next_state = WIN_GAME;	
										
										end
										
						  end
				DROP_ALIEN: next_state = WAIT_DROP_ALIEN;
				WAIT_DROP_ALIEN: next_state = (clearedShift) ? INTAKE: WAIT_DROP_ALIEN;
				KILL_ONE: next_state = WAIT_CLEAR_ONE;
				WAIT_CLEAR_ONE: next_state = (cleared1) ? INTAKE: WAIT_CLEAR_ONE;
				KILL_TWO: next_state = WAIT_CLEAR_TWO;
				WAIT_CLEAR_TWO: next_state = (cleared2) ? INTAKE: WAIT_CLEAR_TWO;
				KILL_THREE: next_state = WAIT_CLEAR_THREE;
				WAIT_CLEAR_THREE: next_state = (cleared3) ? INTAKE: WAIT_CLEAR_THREE;
				KILL_FOUR: next_state = WAIT_CLEAR_FOUR;
				WAIT_CLEAR_FOUR: next_state = (cleared4) ? INTAKE: WAIT_CLEAR_FOUR;
				KILL_FIVE: next_state = WAIT_CLEAR_FIVE;
				WAIT_CLEAR_FIVE: next_state = (cleared5) ? INTAKE: WAIT_CLEAR_FIVE;
				LOSE_GAME: next_state = LOSE_GAME; 
				WIN_GAME: next_state = WIN_GAME;
				
			default: next_state = INTAKE;
			endcase
		end
		
	always @(*)
   begin: enable_signals
				alienTopX <= 8'd0;
				alienBottomX <= 8'd0;
				alienTopY <= 7'd0;
				alienBottomY <= 7'd0;
				scoreCount <= 3'b0;
				gameOver <= 1'b0;
				youWin <= 1'b0; 
				kill1 <= 1'b0; 
				kill2 <= 1'b0; 
				kill3 <= 1'b0; 
				kill4 <= 1'b0; 
				kill5 <= 1'b0; 
				moveDown <= 1'b0;
				
			case (current_state)
			DROP_ALIEN: begin moveDown <= 1'b1; currentYTop <= currentYTop +1; end
			WAIT_DROP_ALIEN: moveDown <= 1'b1;
			KILL_ONE: 
					begin kill1 <= 1'b1; 
							alienTopX <= (startX); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width);
							alienBottomY <= (startY+currentYTop + height);
					end
					
				WAIT_CLEAR_ONE: begin kill1 <= 1'b1;  scoreCount <= scoreCount +1; end//ATTENTION. MIGHT NEED SEP STATE
			
			KILL_TWO : 
					begin kill2 <= 1'b1; 
							alienTopX <= (startX + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap +width);
							alienBottomY <= (startY+currentYTop + height);
					end	
					
				WAIT_CLEAR_TWO: begin kill2 <= 1'b1;  scoreCount <= scoreCount +1; end
			
			KILL_THREE: begin 
							kill3 <= 1'b1; 
							alienTopX <= (startX + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							end
							
				WAIT_CLEAR_THREE: begin kill3 <= 1'b1; scoreCount <= scoreCount +1; end
			
			KILL_FOUR: 	begin
							kill4 <= 1'b1; 
							alienTopX <= (startX + width +gap + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							end
							
				WAIT_CLEAR_FOUR: begin kill4 <= 1'b1; scoreCount <= scoreCount +1;end
			
			KILL_FIVE: begin
							kill5 <= 1'b1; 
							alienTopX <= (startX + width +gap + width + gap + width + gap + width + gap); 
							alienTopY <= (startY+currentYTop); 
							alienBottomX <= (startX + width +gap + width + gap + width + gap + width + gap + width);
							alienBottomY <= (startY+currentYTop + height);
							end
			
				WAIT_CLEAR_FIVE: begin kill5 <= 1'b1; scoreCount <= scoreCount +1;end
			LOSE_GAME: gameOver <= 1'b1;
			WIN_GAME: youWin <= 1'b1;
		
			endcase	
	
end

//state transitions

always@(posedge clk)
	begin: state_transition
	if (~reset)
		begin
			current_state <= INTAKE;
		end
			
		else current_state <= next_state;
	end

		
endmodule

module rate #(parameter CLOCK_FREQUENCY = 5)
							(input clk, input reset, input [1:0] Speed,
							output Enable);

	reg [31:0] count;

	always @( posedge (clk))
		begin	
		
		if(~reset)	
		
				case (Speed)
				2'b10:  count = (CLOCK_FREQUENCY / 3)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
				
			else if (Enable)
			
			case (Speed)
			
				2'b10:  count = (CLOCK_FREQUENCY / 3)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
			
			else if (count > 0) 
			count<=count-1;
		
		
		end	
		assign Enable = (count == 32'b0)?'b1:'b0;		
							//output enable as soon as we count down to 0
				
							
endmodule

	
