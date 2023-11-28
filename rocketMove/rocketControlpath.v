module RocketControl(clk,
							start,
							command_left,//from key
							command_right, //from key
							reset,  //from switch
							screenCleared,
							drewHomebase,
		     					screenClearEn,
							leftEn,
							rightEn
							draw);
							
	input clk, start, command_left, command_right, reset screenCleared, drewHomebase;
	output reg leftEn, rightEn, screenClearEn, drawEn ;
							
	localparam S_TITLE_PAGE = 8'b0 
				  TITLE_WAIT = 8'b1
				  S_CLEAR = 8'b2
				  S_HOMEBASE = 8'b3
				  S_COMMMAND = 8'b4,
				  COMMAND_WAIT = 8'b5
				  S_MOVE_LEFT = 8'b6,
				  S_MOVE_RIGHT = 8'b7;
	
	//states for rocket control
	// COMMAND ready to take in a signal, MOVES will send out signals to the VGA Datapath
	always@(*)
	begin: state_table
		case (current_state)
						S_TITLE_PAGE: next_state = start ? TITLE_WAIT : S_TITLE_PAGE;
						TITLE_WAIT: next_state = start ? TITLE_WAIT :S_CLEAR;
						
						S_CLEAR: next_state = screenCleared ? S_HOMEBASE : S_CLEAR;
						
						S_HOMEBASE: next_state = drewHomebase ? S_COMMAND : S_HOMEBASE;
						
						S_COMMAND: begin
								case (command_left)
										1'b0: next_state = S_COMMAND;
										
												case(commmand_right)
											
												1'b0:next_state = S_COMMAND;
												1'b1:next_state = S_MOVE_RIGHT;
											
												endcase
										
										1'b1: next_state = S_MOVE_LEFT;
								 endcase
						end
						S_MOVE_LEFT:next_state = S_HOMEBASE;
						S_MOVE_RIGHT: next_state = S_HOMEBASE;
						
		default: next_state = S_HOMEBASE;
		endcase
		end
		
		
	 always @(*)
    begin: enable_signals
		screenClearEn = 1'b0;
		leftEn = 1'b0;
		rightEn = 1'b0;
	    	drawEn = 1'b0;
		
		case (current_state)
				S_CLEAR: screenClearEn = 1'b1;
				S_COMMAND: drawEn = 1'b1; 
				S_MOVE_RIGHT: rightEn = 1'b1;
				S_MOVE_LEFT: leftEn = 1'b1;
								
		endcase			
	end
										
	always @ (posedge clk)
	begin reset_conditions
	
		if(resetn == 1'b1) 
			begin
			current_state = S_TITLE_PAGE;
			end
			
			else
			begin
			current_state <= next_state;
			
			end
	end
	
	endmodule
		

								
								
	
endmodule

//
