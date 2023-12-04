module shots(clk, reset, keyPressed, xin, bulletX, bulletY, colour, drawEn, collidedWithAlien);
//xin comes from output of rocket.v - xout from rocket.v 

input clk, reset, keyPressed, collidedWithAlien;
wire updatePosEn, updatedBulletPosition, clearEn, cleared, checkPosEn, checkCompleted, updateDelay, topReached; //remove once aliens module working
input [7:0] xin;
output  [7:0] bulletX;
output  [6:0] bulletY; 
output [2:0] colour;
output drawEn;


datapathshot d0 (.clk(clk), .reset(reset), .updatePosEn(updatePosEn), .clearEn(clearEn), .xin(xin), .bulletX(bulletX),
					.bulletY(bulletY), .topReached(topReached), .colour(colour), .updatedBulletPosition(updatedBulletPosition), .cleared(cleared), .checkPosEn(checkPosEn), .checkCompleted(checkCompleted), .updateDelay(updateDelay));
					
controlpathshot c0 (.clk(clk), .reset(reset), .keyPressed(keyPressed), .topReached(topReached), .collidedWithAlien(collidedWithAlien),
	.updatedBulletPosition(updatedBulletPosition), .updatePosEn(updatePosEn), .clearEn(clearEn), .drawEn(drawEn), .checkPosEn(checkPosEn), .cleared(cleared), .checkCompleted(checkCompleted), .updateDelay(updateDelay));
	
endmodule

module datapathshot (clk, reset, updatePosEn, clearEn, cleared, xin, bulletX, bulletY, topReached, updatedBulletPosition, colour, checkPosEn, checkCompleted, 	updateDelay);
	input clk, reset, updatePosEn, clearEn, checkPosEn, updateDelay;
   input [7:0] xin; 
	wire [7:0] xinorig = xin;
	output reg [7:0] bulletX; 
	output reg [6:0] bulletY; 
//	reg [7:0] xout; 
//	reg [6:0] yout; 
	output reg [2:0] colour;
	output reg topReached, updatedBulletPosition, cleared, checkCompleted;
	reg incremented;
	
	always @(posedge clk)
	begin
		if (~reset) 
			begin
				bulletX <= 8'd0; 
				bulletY <= 7'd105;
				topReached <= 1'b0;
				colour <= 3'b000;
				updatedBulletPosition <= 1'b0;
				topReached <= 1'b0;
				checkCompleted <=1'b0;
				cleared <= 1'b0;
				incremented <= 1'b0;
				
				
			end
			
		else if (clearEn) 
		begin 
			bulletX <= xinorig;
			colour <= 3'b000;
			cleared <= 1'b1;
			checkCompleted <=1'b0;
			topReached <= 1'b0;	
			updatedBulletPosition <= 1'b0;
			incremented <= 1'b0;
			
		end
		
		else if (checkPosEn)
			begin
			if (bulletY == 0)
				begin
					bulletY <= 7'd105;
					bulletX <= 8'd0;
					topReached <= 1'b1;
					cleared <= 1'b0;
					updatedBulletPosition <= 1'b0;
					incremented <= 1'b0;
				end
				else begin 
				checkCompleted <= 1'b1; 
				topReached <= 1'b0;
				cleared <= 1'b0; 
				updatedBulletPosition <= 1'b0;
				incremented <= 1'b0;	end
			end	
			
		else if (updatePosEn && ~incremented) 
					begin
					cleared <= 1'b0;
					checkCompleted <=1'b0;
					topReached <= 1'b0;
					bulletY <= bulletY - 5; //if not at top, move 5 units up - clear and redraw
					colour <= 3'b111;
					updatedBulletPosition <= 1'b1;
					checkCompleted <=1'b0;
					incremented <= 1'b1;
				
							
		end
								
					
end

endmodule



module controlpathshot #(parameter CLOCK_FREQUENCY = 1) (clk, reset, keyPressed, topReached, collidedWithAlien, updatedBulletPosition, cleared, updatePosEn, checkPosEn, clearEn, drawEn, checkCompleted, updateDelay);

	input clk, reset, keyPressed, topReached, collidedWithAlien, updatedBulletPosition, cleared, checkCompleted;
	output reg checkPosEn, updatePosEn, clearEn, drawEn, updateDelay;
	
	reg [2:0] current_state, next_state;
	wire bulletSpeed;
	
	rate #(.CLOCK_FREQUENCY(CLOCK_FREQUENCY)) bullet (.clk(clk), .reset(reset), .Speed(2'b10), .Enable(bulletSpeed));
	
	
	localparam INTAKE = 3'd0, // Set frame counter for top boundary check to 0
				  //if bullet exists - erase it (ex if we reached top of screen or killed an alien)
												
				 CLEAR = 3'd1,  //clear the rocket 
				 
				 CHECK_POSITION = 3'd2, //check for end position and collision
						          
				  
				 UPDATE_POSITION = 3'd3, //update bullet position, draw bullet position,
				
				 UPDATE_WAIT = 3'd4;
				 
				 
	

always @(*)
	begin: state_table
	
	case(current_state)
			INTAKE: next_state = (keyPressed) ? CLEAR : INTAKE;
			
			CLEAR: next_state = (cleared) ? CHECK_POSITION: CLEAR;
			
			CHECK_POSITION: next_state = (collidedWithAlien || topReached) ? INTAKE : (checkCompleted) ? UPDATE_POSITION: CHECK_POSITION;
				
			UPDATE_POSITION: next_state = (updatedBulletPosition) ? UPDATE_WAIT: UPDATE_POSITION;
			
			UPDATE_WAIT: next_state = (bulletSpeed) ? CLEAR: UPDATE_WAIT;
	
		

		default: next_state = INTAKE;
	endcase
end

 
always @(*)
   begin: enable_signals
		checkPosEn <=1'b0;
		updatePosEn <= 1'b0;
		clearEn <= 1'b0;
	   drawEn <= 1'b0;
		updateDelay <= 1'b0;

	case(current_state)
		CLEAR: begin clearEn <= 1'b1; drawEn <= 1'b1; end
		
		CHECK_POSITION: checkPosEn <= 1'b1;
		
		UPDATE_POSITION: begin updatePosEn <= 1'b1; drawEn <= 1'b1; updateDelay <= 1'b1; end
		
		
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


 module rate #(parameter CLOCK_FREQUENCY = 1)
						(input clk, input reset, input [1:0] Speed,
							output Enable);

	reg [31:0] count;

	always @(posedge (clk))
		begin	
		
		if (~reset)	
				
				case (Speed)
				2'b00:  count = (CLOCK_FREQUENCY * 0.5)-1; //shot speed (3 pixels per second)
				2'b10:  count = (CLOCK_FREQUENCY * 4)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
				
			else if (Enable)
			
			case (Speed)
				2'b00:  count = (CLOCK_FREQUENCY * 0.5)-1; //shot speed (3 pixels per second)
				2'b10:  count = (CLOCK_FREQUENCY * 4)-1; //shot speed (3 pixels per second)
				2'b11:  count = (CLOCK_FREQUENCY * 4)-1; //aliens falling (once every 4 seconds)
				endcase
			
			else if (count > 0) 
			count<=count-1;
		
		
		end	
		assign Enable = (count == 32'b0)?'b1:'b0;		
							//output enable as soon as we count down to 0
				
							
endmodule
