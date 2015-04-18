module dff_enable(out, in, enable, clk);
input reg[7:0] in;
input enable, clk;
output reg[7:0] out;

always @(posedge clk) begin
	if (enable) begin
		out = in;
	end
end
endmodule

module two_input_mux(out, input1, input2, enable); //output is either of the two inputs depending on enable
input[3:0] input1, input2;
input enable;
output reg[3:0] out;

always @(posedge clk) begin
	if (enable) begin
		out = input1;
	end
	else if (!enable) begin
		out = input2;
	end
end

endmodule

module adder(out, zeroflag_out, input_a, input_b); //adds two inputs
input reg[7:0] input_a, input_b;
output reg[7:0] out;
output zeroflag_out;

wire and_1_val;

assign out = input_a+input_b;

// for zero flag NAND with result
and and_1(and_1_val, out, 0);
not inv_1(zeroflag_out, and_1_val);

endmodule 

module stack_register(ra_out, a0_out, addr0, addr1, val0, val1, enable, clk); //stack register where all the pushing/popping will happen
//addr0 = sp
//addr1 = sp + 4
//val0 = $a0
//val1 = $ra



endmodule

module fsm(out, a0_zero, clk); //other enables might be necessary, if a0_zero goes high, we're in pop
input a0_zero, clk; //if this is true, then switch from push to pop
output reg[1:0] out;  

always @ (posedge clk) begin

dff_enable pratool(, a0_zero, 1, clk);
end 



endmodule

module cpu;
reg sp_enable, ra_enable, v0_enable; //enables from fsm
reg clk;
reg[7:0] $a0; //initial value we start the fibonnaci sequence from
reg[7:0] $v0, $a1, $a2; //v0 is current, a1 is back 1, a2 is back 2 these values are for adding
reg[7:0] $sp, $ra; //these are when we're building the stack for addition later

endmodule