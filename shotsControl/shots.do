vlib work 
vlog shots.v
vsim -L altera_mf_ver shots
#vsim -L work rocket
log  /*
add wave {/*}
add wave -position end sim:/shots/c0/current_state
add wave -position end sim:/shots/c0/bulletSpeed


force {clk} 0 ns, 1 {0.5ns} -r 1 ns

#RESET

force -deposit reset 0 0 ns
force -deposit reset 1 10 ns

#check transition between INTAKE and CHECK_POSITION
#1 - collided check
force -deposit xin 8'd44 10ns
force  -deposit collidedWithAlien 1'b0 13ns
force -deposit keyPressed 1'd1 12ns
force -deposit keyPressed 1'd0 13ns 

force -deposit collidedWithAlien 1'b1 15ns
force -deposit collidedWithAlien 1'b0 17ns

#2 - hit top check

force -deposit xin 8'd44 20ns
force -deposit xin 8'd30 22ns

force -deposit keyPressed 1'd1 21ns
force -deposit keyPressed 1'd0 22 ns

force -deposit collidedWithAlien 1'b0 25ns
force -deposit topReached 1'b1 25ns
force -deposit topReached 1'b0 27ns

#3 - regular decrements (notice that a second input has no bearing on the outgoing shot) 
force -deposit keyPressed 1'd1 29ns
force -deposit keyPressed 1'd0 30ns

force -deposit keyPressed 1'd1 40ns
force -deposit keyPressed 1'd0 41 ns


run 80ns
