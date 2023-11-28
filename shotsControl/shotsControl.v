module shotsControl (clk, keyPressed, topReached, collidedWith Alien, updatedRocketPosition, userIntakeEn, updatePositionEn, waitingEn );

	input clk, keyPressed, topReached, collidedWithAlien, updatedRocketPosition;
	output reg userIntakeEn, updatePositionEn, waitingEn;
	
	reg [2:0] current_state, next_state;
	
	localparam INTAKE = 2'd0, // -> set frame counter for top boundary check to 0
										//if rocket exists - erase it (ex if we reached top of screen or killed an alien)
												
					
				  UPDATE_POSITION = 2'd1, //update rocket position, draw first rocket position, pass the coordinates back to check for collision
				  
				  WAIT = 2'd2; //check for collisiton, check for top reached, 
	

always @(*)
	begin: state_table
	
	case(current_state)
			INTAKE: next_state = (keyPressed) ? EXECUTE: INTAKE;
			
			UPDATE_POSITION: next_state = (collidedWithAlien || topReached) ? INTAKE: WAIT;
			
			WAIT: next_state = (updatedRocketPosition) ? UPDATE_POSITION : WAIT;
			
	default: next_state = INTAKE;
	endcase
end

 
always @(*)
   begin: enable_signals
	
		userIntakeEn <= 1'b0;
		updatePositionEn <= 1'b0;
		waitingEn <= 1'b0;
		
	case(current_state)
		INTAKE: userIntakeEn <= 1'b1;
		UPDATE_POSITION: updatePositionEn <= 1'b1;
		WAIT: waitingEn <= 1'b1;
	endcase
		
end

//state transitions
always@(posedge clk)
begin: state_transition
		current_state <= next_state;
end;
		
endmodule	
	
			
