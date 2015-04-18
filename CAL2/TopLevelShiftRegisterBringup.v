module TopLevelShiftRegisterBringup(parallel_out, serial_out, button0, switch0, switch1, clk, parallel_in);
    input button0;
    input switch0;
    input switch1;
    input clk;
    input[7:0] parallel_in;
	 output serial_out;
	 output wire [7:0] parallel_out;
	 
	 wire b_conditioned, b_positiveedge, b_negativeedge;
	 wire s0_conditioned, s0_positiveedge, s0_negativeedge;
	 wire s1_conditioned, s1_positiveedge, s1_negativeedge;
	 
	 inputconditioner cond_button (clk, button0, b_conditioned, b_positiveedge, b_negativeedge);
	 inputconditioner cond_switch0 (clk, switch0, s0_conditioned, s0_positiveedge, s0_negativeedge);
	 inputconditioner cond_switch1 (clk, switch1, s1_conditioned, s1_positiveedge, s1_negativeedge);

	//shiftregister(clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut);
	 shiftregister shiftreg1 (clk, s1_positiveedge, b_negativeedge, parallel_in, s0_conditioned, parallel_out, serial_out);

endmodule
