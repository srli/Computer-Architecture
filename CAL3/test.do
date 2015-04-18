vlog -reportprogress 300 -work work fibbtest.v

vsim -voptargs="+acc" testSTACKREGISTER

#add wave -position insertpoint \
#sim:/test2INPUTMUX/input1 \
#sim:/test2INPUTMUX/input2 \
#sim:/test2INPUTMUX/selector \
#sim:/test2INPUTMUX/out 


#add wave -position insertpoint \
#sim:/test_asic/clk \
#sim:/test_asic/fib1_init \
#sim:/test_asic/sum1 \
#sim:/test_asic/sum2 \
#sim:/test_asic/total_sum \

#sim:/testFIB/asic1/v0 \
#sim:/testFIB/asic1/a1 \
#sim:/testFIB/asic1/sp \
#sim:/testFIB/asic1/a0dff/reset_val \
#sim:/testFIB/asic1/a0dff/enable \
#sim:/testFIB/asic1/a0dff/out\
#sim:/testFIB/asic1/fsm1/a0_stackreg \
#sim:/testFIB/asic1/fsm1/FSM_state\
#sim:/testFIB/asic1/fsm1/restart\

#add wave -position insertpoint \
#sim:/testADDER/input_a \
#sim:/testADDER/input_b \
#sim:/testADDER/zeroflag_out \
#sim:/testADDER/out \


#add wave -position insertpoint \
#sim:/test2INPUTMUX/input1 \
#sim:/test2INPUTMUX/input2 \
#sim:/test2INPUTMUX/selector\
#sim:/test2INPUTMUX/out \


#add wave -position insertpoint \
#sim:/test3INPUTMUX/input1 \
#sim:/test3INPUTMUX/input2 \
#sim:/test3INPUTMUX/input3 \
#sim:/test3INPUTMUX/push \
#sim:/test3INPUTMUX/pop \
#sim:/test3INPUTMUX/active \
#sim:/test3INPUTMUX/out \

add wave -position insertpoint \
sim:/testSTACKREGISTER/push \
sim:/testSTACKREGISTER/pop \
sim:/testSTACKREGISTER/addr \
sim:/testSTACKREGISTER/val_in \
sim:/testSTACKREGISTER/val_out \
sim:/testSTACKREGISTER/stack/clk \
sim:/testSTACKREGISTER/stack/push \
sim:/testSTACKREGISTER/stack/pop \
sim:/testSTACKREGISTER/stack/val_out \

run 500
#run 4000
wave zoom full