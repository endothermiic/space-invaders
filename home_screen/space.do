vlib work 
vlog spaceInvaders.v
vsim -L altera_mf_ver 
log  /*
add wave {/*}


force {clk} 0 ns, 1 {5ns} -r 10ns

#RESET
force reset 1'b0;
run 10 ns;
force start 1'b0;
force left  1'b0;
force right 1'b0;
run 100 ns;

#original clear + start + draw in centre 
force reset 1'b1;
run 10 ns;
force start 1'b1;
run 10 ns
force start 1'b0;
run 250000 ns

#move rocket 5 units to left with left pulse
force left 1'b1;
run 1 ns
force left 1'b0;
run 10000 ns


#move rocket another 5 units to left with left pulse
force left 1'b1;
run 10 ns
force left 1'b0;
run 10000 ns

force left 1'b1;
run 10 ns
force left 1'b0;
run 10000 ns


#move rocket another 5 units to right with right pulse
force right 1'b1;
run 10 ns
force right  1'b0;
run 10000 ns

force right 1'b1;
run 10 ns
force right  1'b0;
run 10000 ns
