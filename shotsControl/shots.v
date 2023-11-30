module shots(clk, reset, xin, bulletX, bulletY, colour, drawEn);
//xin comes from output of rocket.v

input clk, reset;
wire updatePosEn, bulletActive, waitEn, topReached, collidedWithAlien, userIntakeEn;
input [7:0] xin;
output [7:0] bulletX;
output [6:0] bulletY; 
output [2:0] colour;
output drawEn;


datapathshot d0 (.clk(clk), .reset(reset), .updatePosEn(updatePosEn), .waitEn(waitEn), .xin(xin), .bulletX(bulletX),
					.bulletY(bulletY), .topReached(topReached), .colour(colour));
controlpathshot c0 (.clk(clk), .keyPressed(keyPressed), .topReached(topReached), .collidedWithAlien(collidedWithAlien),
	.updatedBulletPosition(bulletActive), .userIntakeEn(userIntakeEn), .updatePosEn(updatePosEn), .waitEn(waitEn), .drawEn(drawEn));


endmodule

module datapathshot(clk, reset, updatePosEn, waitEn, xin, bulletX, bulletY, topReached, bulletActive, colour);
	input clk, reset, updatePosEn, waitEn;
	input [7:0] xin; 
	output reg [7:0] bulletX; 
	output reg [6:0] bulletY; 
//	reg [7:0] xout; 
//	reg [6:0] yout; 
	output reg [2:0] colour;
	output reg topReached, bulletActive;
	
	always @(posedge clk)
	begin
		if (reset) 
			begin
				bulletX <= xin; 
				bulletY <= 7'd105;
				topReached <= 1'b0;
				bulletActive <= 1'b0;
			end
		else if (updatePosEn)
			begin
				bulletActive <= 1'b1;
				if (bulletY > 0) 
					begin
						bulletY <= bulletY - 5; //if not at top, move 5 units up - clear and redraw
						colour <= 3'b111;
					end
				else begin
					bulletY <= 7'd105;
					bulletX <= xin;
					topReached <= 1'b1;
				end
			end
		else if (waitEn) colour <= 3'b000;
	end

	
endmodule



module controlpathshot (clk, keyPressed, topReached, collidedWithAlien, updatedBulletPosition, userIntakeEn, updatePosEn, waitEn, drawEn);

	input clk, keyPressed, topReached, collidedWithAlien, updatedBulletPosition;
	output reg userIntakeEn, updatePosEn, waitEn, drawEn;
	
	reg [2:0] current_state, next_state;
	
	localparam INTAKE = 2'd0, // Set frame counter for top boundary check to 0
				  //if bullet exists - erase it (ex if we reached top of screen or killed an alien)
												
					
				  UPDATE_POSITION = 2'd1, //update bullet position, draw bullet position, 
						          //pass the coordinates to the alienTalentManager back to check for collision
				  
				  WAIT = 2'd2; //check for collision, check for top reached, 
	

always @(*)
	begin: state_table
	
	case(current_state)
			INTAKE: next_state = (keyPressed) ? UPDATE_POSITION : INTAKE;
			
			UPDATE_POSITION: next_state = (collidedWithAlien || topReached) ? INTAKE: WAIT;
			
			WAIT: next_state = (updatedBulletPosition) ? UPDATE_POSITION : WAIT;

		default: next_state = INTAKE;
	endcase
end

 
always @(*)
   begin: enable_signals
	
		userIntakeEn <= 1'b0;
		updatePosEn <= 1'b0;
		waitEn <= 1'b0;
	   drawEn <= 1'b0;
		
	case(current_state)
		INTAKE: userIntakeEn <= 1'b1;
		UPDATE_POSITION: begin updatePosEn <= 1'b1; drawEn <= 1'b1; end
		WAIT: waitEn <= 1'b1;
	endcase
		
end

//state transitions
always@(posedge clk)
	begin: state_transition
			current_state <= next_state;
	end
endmodule
