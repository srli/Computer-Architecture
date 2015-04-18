vlog -reportprogress 300 -work work spimemory3.v finitestatemachine.v shiftregister.v inputconditioner.v tristatebuffer.v dff.v datamemory.v
vsim -voptargs="+acc" testSPIMemory
virtual type {{0 GET} {1 GOT} {2 READ1} {3 READ2} {4 READ3} {5 WRITE1} {6 WRITE2} {7 DONE}} state_type
virtual function {(state_type) /testSPIMemory/spimem/fsm/state} state_virtual
add wave -position insertpoint \
sim:/testSPIMemory/clk \
sim:/testSPIMemory/spimem/sclk_conditioned \
sim:/testSPIMemory/mosi \
sim:/testSPIMemory/miso \
sim:/testSPIMemory/spimem/dff_thing/q \
sim:/testSPIMemory/spimem/dff_thing/d \
sim:/testSPIMemory/spimem/dm_dout \
sim:/testSPIMemory/spimem/address \
sim:/testSPIMemory/spimem/parallelDataOut \
sim:/testSPIMemory/spimem/data_mem/tempreg1 \
sim:/testSPIMemory/spimem/data_mem/address \
sim:/testSPIMemory/spimem/fsm/cs_conditioned \
sim:/testSPIMemory/spimem/fsm/sclk_positiveedge \
sim:/testSPIMemory/spimem/fsm/count \
sim:/testSPIMemory/spimem/fsm/state_virtual
run 110000
wave zoom full