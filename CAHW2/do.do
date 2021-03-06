vlog -reportprogress 300 -work work decoder.v multiplexer.v adder.v
vsim -voptargs="+acc" testDecoder
add wave -position insertpoint  \
sim:/testDecoder/addr0 \
sim:/testDecoder/addr1 \
sim:/testDecoder/enable \
sim:/testDecoder/out0 \
sim:/testDecoder/out1 \
sim:/testDecoder/out2 \
sim:/testDecoder/out3
run -all

vsim -voptargs="+acc" testMultiplexer
add wave -position insertpoint  \
sim:/testMultiplexer/addr0 \
sim:/testMultiplexer/addr1 \
sim:/testMultiplexer/in0 \
sim:/testMultiplexer/in1 \
sim:/testMultiplexer/in2 \
sim:/testMultiplexer/in3 \
sim:/testMultiplexer/out
run -all

vsim -voptargs="+acc" testFullAdder
add wave -position insertpoint \
sim:/testFullAdder/a \
sim:/testFullAdder/b \
sim:/testFullAdder/carryin \
sim:/testFullAdder/carryout \
sim:/testFullAdder/sum


run -all
wave zoom full

run 100