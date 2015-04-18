vlog -reportprogress 300 -work work fourbitadder.v
vsim -voptargs="+acc" testFullAdder
add wave -position insertpoint  \
sim:/testFullAdder/a \
sim:/testFullAdder/b \
sim:/testFullAdder/sum \
sim:/testFullAdder/overflow
run -all
wave zoom full
run 100