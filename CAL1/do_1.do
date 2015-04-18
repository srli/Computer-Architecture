vlog -reportprogress 300 -work work ALU.v
vsim -voptargs="+acc" ALU_testbench
#vsim -voptargs="+acc" testand 
#vsim -voptargs="+acc" testnor
#add wave -position insertpoint  \
#sim:/testMultiplexer/address0 \
#sim:/testMultiplexer/address1 \
#sim:/testMultiplexer/out \
#sim:/testMultiplexer/in0 \
#sim:/testMultiplexer/in1 \
#sim:/testMultiplexer/in2 \
#sim:/testMultiplexer/in3 \

#sim:/testDecoder/addr0 \
#sim:/testDecoder/addr1 \
#sim:/testDecoder/enable \
#sim:/testDecoder/out0 \
#sim:/testDecoder/out1 \
#sim:/testDecoder/out2 \
#sim:/testDecoder/out3 \

#add wave -position insertpoint  \
#sim:/testFullAdder/a \
#sim:/testFullAdder/b \
#sim:/testFullAdder/carryin \
#sim:/testFullAdder/sum \
#sim:/testFullAdder/carryout \

run -all
#wave zoom full