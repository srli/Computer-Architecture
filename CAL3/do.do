vlog -reportprogress 300 -work work fibbasic.v

vsim -voptargs="+acc" testFIB
add wave -position insertpoint \
sim:/testFIB/asic1/v0 \
sim:/testFIB/asic1/a1 \
sim:/testFIB/asic1/sp \
sim:/testFIB/asic1/a0dff/reset_val \
sim:/testFIB/asic1/a0dff/enable \
sim:/testFIB/asic1/a0dff/out\
sim:/testFIB/asic1/fsm1/a0_stackreg \
sim:/testFIB/asic1/fsm1/FSM_state\
sim:/testFIB/asic1/fsm1/restart\

run 500
#run 4000
wave zoom full