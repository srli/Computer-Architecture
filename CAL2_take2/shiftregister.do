vlog -reportprogress 300 -work work shiftregister.v
vsim -voptargs="+acc" testshiftregister

add wave -position insertpoint  \
sim:/testshiftregister/clk \
sim:/testshiftregister/peripheralClkEdge \
sim:/testshiftregister/serialDataIn \
sim:/testshiftregister/serialDataOut \
sim:/testshiftregister/parallelLoad
run 2600

wave zoom full