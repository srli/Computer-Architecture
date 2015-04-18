`define AND and #10
`define OR or #10
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #10

`define ADDop 3'd0
`define SUBop 3'd1
`define XORop 3'd2
`define SLTop 3'd3
`define ANDop 3'd4
`define NANDop 3'd5
`define NORop 3'd6
`define ORop 3'd7

module xorgate(a, b, out);
output[31:0] out;
input[31:0] a, b;

generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: andgen
		`XOR xor1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

module andgate(a, b, out);
output[31:0] out;
input[31:0] a, b;

//Note this gate is also used to create NOR (if the inputs 'a' and 'b' are inverted)

generate //create an and gate to compare every bit for the 32 bits in 'a' and 'b'
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: andgen
		`AND and1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

module orgate(a, b, out);
output[31:0] out;
input[31:0] a, b;

//Note this gate is also used to create 'NAND' (if 'a' and 'b' are inverted)

generate //Generate 32 'or' gates to compare each of the bits in 'a' and 'b'
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: orgen
		`OR or1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

module adder(sum, Co, A, B, Ci);
//initialize the inputs and outputs
output sum, Co;
input A, B, Ci;

//define the inverses of A, B, and Ci
`NOT invA(notA, A);
`NOT invB(notB, B);
`NOT invCi(notCi, Ci);

//define the 4 AND gates that get fed into the summing OR gate.
`AND andGate0(notAnotBCi, notA, notB, Ci);
`AND andGate1(notABnotCi, notA, B, notCi);
`AND andGate2(ABCi, A, B, Ci);
`AND andGate3(AnotBnotCi, A, notB, notCi);

//define the 3 AND gates that get fed into the carrying OR gate. There should be 4, but we know that ABCi + AnotBCi = ACi
`AND andGate4(notABCi, notA, B, Ci);
`AND andGate5(ABnotCi, A, B, notCi);
`AND andGate6(ACi, A, Ci);

//Define the OR gates that output the sum and the carryout respectively.
`OR orGateSum(sum, notAnotBCi, notABnotCi, ABCi, AnotBnotCi);
`OR orGateCarry(Co,ABnotCi,notABCi,ACi);
endmodule

module add32Bit(sum,carryout,overflow,a,b, ci);
output[31:0] sum; // 2?s complement sum of a and b
output carryout; // Carry out of the summation of a and b
output overflow; // True if the calculation resulted in an overflow
input[31:0] a; // First operand in 2?s complement format
input[31:0] b; // Second operand in 2?s complement format
input ci;
wire[32:0] co;
assign co[0] = ci;
generate
genvar index;
for (index = 0; index<32; index = index + 1) begin
adder genAdder(sum[index], co[index+1], a[index], b[index], co[index]);
end
endgenerate
`XOR(overflow, co[32], co[31]);
assign carryout = co[32];
endmodule

module structuralMultiplexer(out, address0,address1, address2, in0,in1,in2,in3,in4);
output[31:0] out;
input address0, address1, address2;
input[31:0] in0; //AND/NOR
input[31:0] in1; //OR/NAND
input[31:0] in2; //XOR
input[31:0] in3; //ADD/SUB
input in4; //SLT

//wire[31:0] addex0, addex1, addex2, addex_inv0, addex_inv1, addex_inv1;
//wire[31:0] in4ex;

`NOT notaddress0(addr0_inv, address0);
`NOT notaddress1(addr1_inv, address1);
`NOT notaddress2(addr2_inv, address1);

`AND in4_and(in4and, in4, address0, addr1_inv, addr2_inv); //in4 is SLT

generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: muxgen
		`AND in0_and(in0and[index], in0[index], addr0_inv, addr1_inv, addr2_inv); //in0 is AND/NOR
		`AND in1_and(in1and[index], in1[index], addr0_inv, addr1_inv, address2); //in1 is OR/NAND
		`AND in2_and(in2and[index], in2[index], addr0_inv, address1, addr2_inv); //in2 is XOR
		`AND in3_and(in3and[index], in3[index], addr0_inv, address1, address2); //in3 is ADD/SUB
		`OR or1(out[index], in0and[index], in1and[index], in2and[index], in3and[index], in4and);
	end
endgenerate
endmodule

module LUT(mux_command, a_inv, b_inv, carry_in, allow_overflow, addr);
output reg[2:0] mux_command;
output reg a_inv;
output reg b_inv;
output reg carry_in;
output reg allow_overflow;
input[2:0] addr;
//LUT generates command signals for the logic inside the ALU
always @ (addr) begin
case(addr)
`ADDop: begin mux_command = 3'b000; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 1; end //To add don't invert a or b
`SUBop: begin mux_command = 3'b000; a_inv = 0; b_inv = 1; carry_in = 1; allow_overflow = 1; end //To subtract invert b and add 1 (can be done by starting carry chain at 1 instead of 0
`XORop: begin mux_command = 3'b001; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 0; end //XOR doesn't need anything special;
`SLTop: begin mux_command = 3'b010; a_inv = 0; b_inv = 1; carry_in = 1; allow_overflow = 0; end //SLT behaves like subtract, but does not allow overflow
`ANDop: begin mux_command = 3'b011; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 0; end //AND doesn't need anything special
`NORop: begin mux_command = 3'b011; a_inv = 1; b_inv = 1; carry_in = 0; allow_overflow = 0; end //NOR is just AND with inverse inputs
`ORop: begin mux_command = 3'b100; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 0; end //OR doesn't need any special inputs
`NANDop: begin mux_command = 3'b100; a_inv = 1; b_inv = 1; carry_in = 0; allow_overflow = 0; end //NAND is just OR with inverse inputs
default: $display("Please check inputs");
endcase
end
endmodule
module ALU(a, b, addr, out, carry_out, over_flow, zero);
input[31:0] a, b;
input[2:0] addr; //TO-DO SHORTEN TO 2 BITS IF NECESSARY
output[31:0] out;
output carry_out, over_flow, zero
wire carry_in, b_inv; //determines between ADD/SUB
wire a_inv, allow_overflow; //a_inv determines between NAND/NOR, allow_overflow is needed SLT
wire[2:0] mux_command;
reg[31:0] A, B; //xor with inv_a, inv_b


//Calls the look up table with the command given 
LUT lookuptable(mux_command, a_inv, b_inv, carry_in, allow_overflow, addr)

//LOGIC
generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: abinv_gen
		`XOR a_invgen(A[index], a[index], a_inv); //in0 is AND/NOR
		`XOR b_invgen(B[index], b[index], b_inv); //in1 is OR/NAND
	end
endgenerate

andgate and_gate(A, B, ando); //AND/NOR
orgate or_gate(A, B, oro); //OR/NAND
xorgate xor_gate(A, B, xoro); //XOR
add32bit add_gate(addo, carryout, overflow, A, B, carry_in); //ADD/SUB, if b_inv, then we're doing subtract

`AND allowoverflow_and(overflow, overflow, allow_overflow);
//SLT

//Calls MUX with what we've done with logic




endmodule
module ALU_testbench
initial begin
$display("Testing selects");
$display("a                                 b                                |  out                   |zero              | Expected");
addr=`ANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |  0000000000000000000000000000000", a, b, out, zero);
addr=`ANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000001; #5000 //simplest and test returns false
$display("%b  %b |  %b    | %b  |   0000000000000000000000000000001", a, b, out, zero);
addr=`ANDop;a=32'b10101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 //all 0's test
$display("%b  %b |  %b    | %b  |   0000000000000000000000000000000", a, b, out, zero);
addr=`ANDop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //all 1's test
$display("%b  %b |  %b    | %b  |   11111111111111111111111111111111", a, b, out, zero);


addr=`ORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |    0000000000000000000000000000000", a, b, out, zero);
addr=`ORop;a=32'b10101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 //all 1's test
$display("%b  %b |  %b    |  %b  |    0000000000000000000000000000000", a, b, out, zero);
addr=`ORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //all 1's test
$display("%b  %b |  %b    |  %b  |    11111111111111111111111111111111", a, b, out, zero);
addr=`ORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |    00000000000000000000000000000000", a, b, out, zero);

addr=`NANDop;a=32'11111111111111111111111111111111;b=32'11111111111111111111111111111111; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |     00000000000000000000000000000000", a, b, out, zero);
addr=`NANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000001; #5000 //simplest and test returns true
$display("%b  %b |  %b    |  %b  |     11111111111111111111111111111110", a, b, out, zero);
addr=`NANDop;a=32'b10101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 //all 1's test
$display("%b  %b |  %b    |  %b  |     11111111111111111111111111111111", a, b, out, zero);
addr=`NANDop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |     0000000000000000000000000000000", a, b, out, zero);

addr=`NORop;a=32'11111111111111111111111111111111;b=32'11111111111111111111111111111111; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |     00000000000000000000000000000000", a, b, out, zero);
addr=`NORop;a=32'b10101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |     0000000000000000000000000000000", a, b, out, zero);
addr=`NORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |     0000000000000000000000000000000", a, b, out, zero);


addr=`XORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |   0000000000000000000000000000000", a, b, out, zero);
addr=`XORop;a=32'b10101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 //all 1's test
$display("%b  %b |  %b    |  %b  |   11111111111111111111111111111111", a, b, out, zero);
addr=`XORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //all 0's test
$display("%b  %b |  %b    |  %b  |   0000000000000000000000000000000", a, b, out, zero);

$display("These tests have positive addends and don't have overflow");

addr=`ADDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b  %b  %b  |  %b   |   0000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);  //all zeros
addr=`ADDop;a=32'b00101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 
$display("%b  %b |  %b   %b  %b |  %b   |   01111111111111111111111111111111", a, b, sum, over_flow, carry_out, zero); //almost all 1's.
addr=`ADDop;a=32'b00000000111111110000000011111111;b=32'b00000000000000000000000011111111; #5000 
$display("%b  %b |  %b   %b   %b |  %b  |   00000000111111110000000111111110", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01000000000000000000000000000000;b=32'b00000000000000000000000000000011; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   01000000000000000000000000000011", a, b, sum, over_flow, carry_out, zero);

$display("These tests have positive addends and have overflow");

addr=`ADDop;a=32'b01111111111111111111111111111111;b=32'b01111111111111111111111111111111; #5000 //positive with overflow
$display("%b  %b |  %b   %b   %b |  %b  |    01111111111111111111111111111110", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01110000000000000000000000000000;b=32'b01100000000000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b |  %b  |    0110100000000000000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b00000000111111111111111111111111;b=32'b11111111100000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b |  %b  |    01111111111111111111111111111111", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01010101010101010101010101010101;b=32'b01110101010101010101010101010101; #5000 
$display("%b  %b |  %b   %b   %b | %b   |    01100101010101010101010101010100", a, b, sum, over_flow, carry_out, zero);

$display("These tests have two negative addends with overflow.");

addr=`ADDop;a=32'b10000000111111110000000000000000;b=32'b10000000000000000000000000000001; #5000 
$display("%b  %b |  %b    | 010000000011111111000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10000000000000000011111100000000;b=32'b10000000000000000001111100000001; #5000 
$display("%b  %b |  %b    | 010000000000000000010111100000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10000000000000000000000000000000;b=32'b10000000000000000001111100000001; #5000 
$display("%b  %b |  %b    | 010000000000000000010111100000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10000000000000000000000000000000;b=32'b10000000000000000001111100000001; #5000 
$display("%b  %b |  %b    | 010000000000000000010111100000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10000000000000011110000000000000;b=32'b10000000000000000001111100000001; #5000 
$display("%b  %b |  %b    | 010000000000000001111111110000000", a, b, sum, over_flow, carry_out, zero);

$display("These tests have two negative addends without overflow.");

addr=`ADDop;a=32'b1111111111111111101100011110000;b=32'b1111111111111111111111100000110; #5000 
$display("%b  %b |  %b    | 11111111111111111101011111110110", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b1000000000000000000000000000000;b=32'b1000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 10000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`ADDop;a=32'b11111111111111111111111111111100;b=32'b11111111111111111111111111111110; #5000 
$display("%b  %b |  %b    | 11111111111111111111111111111111", a, b, sum, over_flow, carry_out, zero);

$display("These tests are subtraction, with two positive terms without overflow. A negative and a positive number added cannot give overflow.");

addr=`SUBop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000  //positive no overflow
$display("%b  %b |  %b  %b  %b  |  %b   |   00000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);  //all zeros
addr=`SUBop;a=32'b00101010101010101010101010101010;b=32'b01010101010101010101010101010101; #5000 
$display("%b  %b |  %b   %b  %b |  %b   |   01010101010101010101010101010110", a, b, sum, over_flow, carry_out, zero); //almost all 1's.
addr=`SUBop;a=32'b00000000111111110000000011111111;b=32'b00000000000000000000000011111111; #5000 
$display("%b  %b |  %b   %b   %b |  %b  |   00000000011111111000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`SUBop;a=32'b01000000000000000011111000000000;b=32'b00001111100000000000000000000011; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00011000010000000001111011111111", a, b, sum, over_flow, carry_out, zero);

$display("These tests test the SLT function.");
addr=`SLTop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00011111000000000000000000000000;b=32'b00011111000000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00000000000000000000000000000111;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00000000000000000000000000000001", a, b, sum, over_flow, carry_out, zero);
addr=`SLTop;a=32'b11110000000000000000000000000000;b=32'b00000000000000000000000000000111; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00000000000000000000000000000000", a, b, sum, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00000000000000000000000000000111;b=32'b11110000000000000000000000000000; #5000 
$display("%b  %b |  %b   %b   %b | %b   |   00000000000000000000000000000001", a, b, sum, over_flow, carry_out, zero);


end
endmodule