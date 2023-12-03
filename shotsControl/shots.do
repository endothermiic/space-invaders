vlib work 
vlog shots.v
vsim -L altera_mf_ver shots
#vsim -L work rocket
log  /*
add wave {/*}
add wave -position end  sim:/shots/c0/current_state

force {clk} 0 ns, 1 {5ns} -r 10ns

#RESET
force reset 1'b0
run 30 ns

#rocket position
force xin 8'd45
force keyPressed 1'd1
force reset 1'b1
run 10 ns
force keyPressed 1'd0
run 25000 ns
