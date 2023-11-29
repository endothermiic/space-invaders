vlib work 
vlog rocket.v
vsim -L altera_mf_ver rocket
#vsim -L work rocket
log  /*
add wave {/*}

add wave -position insertpoint  \
sim:/rocket/c0/current_state \
sim:/rocket/c0/next_state

add wave -position insertpoint  \
sim:/rocket/xStart
add wave -position insertpoint  \
sim:/rocket/yStart
add wave -position insertpoint  \
sim:/rocket/d0/rocketCleared

add wave -position end  sim:/rocket/d0/xorig
add wave -position end  sim:/rocket/d0/yorig


force {clk} 0 ns, 1 {5ns} -r 10ns

#RESET
force reset 1'b1;
run 10 ns;
force start 1'b0;
force left  1'b0;
force right 1'b0;
run 10ns

#original clear + start + draw in centre 
force reset 1'b0;
force start 1'b1;
run 250000 ns

#move rocket 5 units to left with left pulse
force left 1'b1;
run 10 ns
force left 1'b0;
run 10000 ns


#move rocket another 5 units to left with left pulse
force left 1'b1;
run 10 ns
force left 1'b0;
run 10000 ns

