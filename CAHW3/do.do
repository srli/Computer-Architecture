vlog -reportprogress 300 -work work register4.v
#vsim -voptargs="+acc" test32
vsim -voptargs="+acc" hw4testbenchharness

run -all