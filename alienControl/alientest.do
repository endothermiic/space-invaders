vlib work
vlog alienTalentManager.v

vsim alienTalentManager

log {/*}
add wave {/*}

force {clk} 0 ns, 1 {3ns} -r 6ns

#RESET
force reset 1'b1;
run 2 ns;
force reset 1'b0;
run 2 ns;
force reset 1'b1;


force clearedShift 1'b0;
run 10ns;
force clearedShift  1'b1;
run 
# Check drop

run 7000 ns;

# Collision
#force shotXcoord 8'b10;
#force shotYcoord 7'b20;
#force {clearedShift} 0 ns, 1 {20ns} -r 22ns
#run 100 ns;

#force cleared1 1'b1;
#run 10 ns;

