vlog -reportprogress 300 -work work shiftregister.v
vsim -voptargs="+acc" testshiftregister
add wave -position insertpoint \
sim:/testshiftregister/parallelDataOut \
sim:/testshiftregister/serialDataOut \

run -all
wave zoom full