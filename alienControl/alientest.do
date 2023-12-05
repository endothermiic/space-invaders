vlib work
vlog alienTalentManager.v

vsim alienTalentManager

log {/*}
add wave {/*}

force {clk} 0 ns, 1 {3ns} -r 6ns


#RESET AND INITIALIZE AS DATAPATH WOULD
force -deposit reset 1'b1 0ns;
force -deposit reset 1'b0 3ns;
force -deposit reset 1'b1 6ns;
force -deposit startRow 1'b0 0ns
force -deposit clearedShift 1'b0 0ns;
force -deposit incremented 1'b1 0ns;
force -deposit cleared1 1'b0 70ns;
force -deposit cleared2 1'b0 70ns;
force -deposit cleared3 1'b0 70ns;
force -deposit cleared4 1'b0 70ns;
force -deposit cleared5 1'b0 70ns;

#CHECK IF WE STAY IN THE FIRST_STATE until the start row goes high
force -deposit startRow 1'b1 19ns

#give enough time to go into state DROP_ALIEN, then clear
force -deposit clearedShift 1'b1 60ns;
force -deposit clearedShift 1'b0 63ns;


#CHECK COLLISION 1 (y coordintes smaller than the current position)
force -deposit shotXcoord 8'd14 70nsl
force -deposit shotYcoord 7'd5 70ns;
force -deposit clearedShift 1'b1 75ns;

force -deposit cleared1 1'b1 100ns;

#CHECK IF WE CAN ONLY KILL EACH ALIEN ONCE
force -deposit shotXcoord 8'd14 140nsl
force -deposit shotYcoord 7'd0 140ns;

#COLLISION 2
force -deposit shotXcoord 8'd45 200nsl
force -deposit shotYcoord 7'd0 200ns;

force -deposit cleared2 1'b1 205ns;

#COLLISION 3
force -deposit shotXcoord 8'd76 300nsl
force -deposit shotYcoord 7'd0 300ns;

force -deposit cleared3 1'b1 305ns;

#COLLISION 4


force -deposit shotXcoord 8'd107 400ns;
force -deposit shotYcoord 7'd0 400ns;

force -deposit cleared4 1'b1 405ns;

#COLLISION 5


force -deposit shotXcoord 8'd140 500ns;
force -deposit shotYcoord 7'd0 500ns;

force -deposit cleared5 1'b1 505ns;





run 600 ns;
