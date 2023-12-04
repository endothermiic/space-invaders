vlib work
vlog aliensMove.v

vsim -L altera_mf_ver aliensMove

log {/*}
add wave {/*}

add wave -position end sim:/aliensMove/d1/a0/address

add wave -position end sim:/aliensMove/c1/current_state
add wave -position end sim:/aliensMove/c1/next_state
add wave -position end sim:/aliensMove/c1/drop


add wave -position end sim:/aliensMove/c1/scoreCount


#add wave -position end sim:/aliensMove/startRow

force {clk} 0 ns, 1 {0.5ns} -r 1ns

#RESET

force -deposit reset 0 0 ns
force -deposit reset 1 10 ns

#force -deposit xtop 11'd9 1700 ns
#force -deposit ytop 11'd10 1700  ns
#force -deposit xbottom 11'd20 1700  ns
#force -deposit ybottom 11'd19 1700  ns
#force -deposit clear1 1'b1 1700  ns

##SEE HERE. INCREMENTS, CLEARS, BUT DOES NOT BUT UP THE CLEARED FLAG
force -deposit shotXCoord 8'd12 3200 ns
force -deposit shotYCoord 8'd20 3200 ns



force -deposit shotXCoord 8'd34 4900 ns
force -deposit shotYCoord 8'd2 4900 ns


run 9000 ns
