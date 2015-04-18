module testADDER;
reg[7:0] input_a, input_b;
wire zeroflag_out, sum;

adder adder_1 (sum, zeroflag_out, input_a, input_b); 

always #5 clk = ~clk; 

initial begin
$display("Input A | Input B | Zero Flag Out | Sum");
$display("Adds the values 3 and 1");
input_a = 3; input_b = 1; #100; 
$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en); 
$display("Adds the values 3 and -1");
input_a = 3; input_b = 4'b1111; #100; 
$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en); 
$display("Adds the values 3 and 6");
input_a = 3; input_b = 6; #100; 
$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en); 
end
endmodule

module testFSM;
reg clk; 
reg [7:0] $a0_out;
reg restart; 
wire push_en, pop_en, active_en; 

fsm fsm_1(push_en, pop_en, active_en, addr_zero, a0_initial, a0_stackreg, clk, restart); 

always #5 clk = ~clk; 

initial begin
//testing going from push to pop 

$display("Addr Zero | Restart | Push Enable | Pop Enable | Active Enable");
$display("This test case tests the transition from push to pop.");
addr_zero = 1; restart = 0; a0_initial=0; a0_stackreg=0 #100
$display("%b, %b, %b, %b, %b, %b, %b", addr_zero, a0_initial, a0_stackreg, restart, push_en, pop_en, active_en);
//$display("This test case tests the transition from pop to done");
//addr_zero = 0; restart = 0; #100
//$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en);
//$display("This test case tests the transition from done to push.");
//addr_zero = 0; restart = 1; #100
//$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en);
//$display("This test case tests the restart while in the pop stage.");
//addr_zero = 1; restart = 1; #100
//$display("%b, %b, %b, %b, %b", addr_zero, restart, push_en, pop_en, active_en); 
end
endmodule 

module testFIB;  
reg[7:0] a0_init; 
wire reset; 

wire v0; 
wire done; 
top_level_asic pratool(v0, done, a0_init, clk, reset_button); 
always #5 clk = ~clk; 

initial begin 
$display("Initial Value | Reset | Done flag | Output"); 
$display("This test case tests the entire asic.");
a0_init = 7;
$display ("Asks for the fibbonaci of 7 terms"); 
$display("%b, %b, %b, %b", a0_init, reset, done, v0); 
a0_init = 0;
$display("Asks for the fibbonaci of 0 terms");
$display("%b, %b, %b, %b", a0_init, reset, done, v0); 
a0_init = 4'b0111; 
$display("Asks for the fibbonaci of 32 terms");
$display("%b, %b, %b, %b", a0_init, reset, done, v0); 
a0_init = 32;
$display("Asks for the fibbonaci of 32 terms");
$display("%b, %b, %b, %b", a0_init, reset, done, v0); 
end 
endmodule 

module test2INPUTMUX;  
reg [3:0] input1,input2;
wire selector; 
wire out; 
two_input_mux mux(out, input1, input2, selector); //output is either of the two inputs depending on enable
always #5 clk = ~clk; 

initial begin 
$display("Input1 | Input2 | Selector | Out"); 
input1 = 4'b0010;input2 = 4'b0100; selector = 1; 
$display("%b, %b, %b, %b", input1, input2, selector, out); 
end 
endmodule

module test3INPUTMUX;  
reg [3:0] input1,input2,input3;
wire push, pop, active; 
wire selector; 
reg[7:0] out; 

three_input_mux mux1(out, input1, input2, input3, push, pop, active);

always #5 clk = ~clk; 

initial begin 
$display("Input1, Input2, Input3 | Push, Pop, Active | Selector | Out"); 
input1 = 4'b0010;input2 = 4'b0100; input3 = 4'b1000; selector = 1; 
$display("%b, %b, %b, %b, %b, %b, %b", input1, input2, input3, push, pop, active, selector, out); 
end 
endmodule


module testDFF; 
wire [7:0] in, reset_val;
wire enable, clk, reset_button;
reg[7:0] out;

dff_enable dff(out, in, enable, clk, reset_val, reset_button);
always #5 clk = ~clk; 
initial begin 
$display("In Enable | Reset Button| Reset Value | Out"); 
$display("");
in = ; reset_val = ; enable = ; reset_button = ; 
$display("%b, %b, %b, %b, %b, %b, %b, %b", in, enable, reset_button, reset_val, out); 

end 

endmodule 

module testSTACKREGISTER; //NEED TO ADD RESET
wire push, pop;
wire[7:0] addr, val_in;

reg[7:0] val_out; 

stack_register stack(val_out, addr, val_in, push, pop, clk); 
always #5 clk = ~clk; 
initial begin 
$display("Address, Value In | Push, Pop | Value Out"); 
$display("There are only 32 registers, this is calling a hidden register");
push = 1; pop = 0; addr = 35; val_in = 7; restart = 0; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out);

$display("Writing value 7 to address 5");
push = 1; pop = 0; addr = 5; val_in = 7; restart = 0; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out); 

$display("Reading address 5. Expect to read a val_out of 7.");
push = 0; pop = 1; addr = 5; val_in = 7; restart = 0; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out); 

$display("This test case reads address 8. Value should be 0 because has not been writing too.");
push = 0; pop = 1; addr = 8; val_in = 7; restart = 0; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out); 

$display("Attempts to write the value 7 to address 9. However, restart is on. Expect no writing to occur");
push = 1; pop = 0; addr = 9; val_in = 7; restart = 1; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out); 

$display("Reads address 9. However, since restart was on while writing, this should read the stack initial value of 0.");
push = 1; pop = 0; addr = 9; val_in = 7; restart = 1; 
$display("%b, %b, %b, %b, %b, %b, %b", addr, val_in, push, pop, val_out);
end 
endmodule
