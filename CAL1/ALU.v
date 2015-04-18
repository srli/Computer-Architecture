//Defining gates, we're adding 10ms delays to each gate
`define AND and #20
`define OR or #20
`define NOT not #10
`define NOR nor #10
`define NAND nand #10
`define XOR xor #30

//Defining each operation so it's in more human readable format
`define ADDop 3'd0
`define SUBop 3'd1
`define XORop 3'd2
`define SLTop 3'd3
`define ANDop 3'd4
`define NANDop 3'd5
`define NORop 3'd6
`define ORop 3'd7

module xorgate(a, b, out);
//Outputs the exlcusive or of inputs a and b
// if a is different than b, out should be 1 otherwise 0
output[31:0] out;
input wire[31:0] a, b;
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: xorgen
		`XOR xor1(out[index], a[index], b[index]);
	end
endgenerate
endmodule
module andgate(a, b, out);
//Outputs the result of inputs a and b passing through an and gate
//output will only b 1 if both the inputs are 1
output[31:0] out;
input[31:0] a, b;

//Note this gate is also used to create NOR (if the inputs 'a' and 'b' are inverted)

generate //create an and gate to compare every bit for the 32 bits in 'a' and 'b' 
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: andgen
		`AND and1(out[index], a[index], b[index]); //Result added to the output
	end
endgenerate
endmodule

module orgate(a, b, out);
//Outputs the result of inputs a and b passing through an or gate
//out will be 1 if either/both of the inputs are 1
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

module adder(sum, carryout, a, b, carryin);
//Takes in two bits and returns the arithmatic sum and the carryout
output sum, carryout;
input a, b, carryin;

`NOT nota(a_inv, a);
`NOT notb(b_inv, b);
`NOT notcarryin(carryin_inv, carryin);

`AND nanbc(na_nb_c, a_inv, b_inv, carryin);
`AND nabnc(na_b_nc, a_inv, b, carryin_inv);
`AND anbnc(a_nb_nc, a, b_inv, carryin_inv);
`AND abc(a_b_c, a, b, carryin);
`OR sumbit(sum, na_nb_c, na_b_nc, a_nb_nc, a_b_c);

`AND bc(b_c, b, carryin);
`AND ac(a_c, a, carryin);
`AND ab(a_b, a, b);
`OR cout(carryout, b_c, a_c, a_b);

endmodule

module adder32Bit(addo, carryout, over_flow, A, B, carry_in);
//Chains together 32 1 bit adders and outputs the arithmatic sum, the carryout, and the overflow
output[31:0] addo; // 32 signed binary sum of a and b
output carryout; // Carry out of the summation of a and b
output over_flow; // True if the calculation resulted in an overflow
input[31:0] A; // First operand in 2?s complement format
input[31:0] B; // Second operand in 2?s complement format
input carry_in;

// Your Code Here
wire[31:0] carry_oarray;

adder adder_init (addo[0], carry_oarray[0], A[0], B[0], carry_in);
adder adder1 (addo[1], carry_oarray[1], A[1], B[1], carry_oarray[0]);

generate //Generate 32 'or' gates to compare each of the bits in 'a' and 'b'
genvar index;
for (index = 2; index<32; index = index + 1)
	begin: add32b
	adder addergen (addo[index], carry_oarray[index], A[index], B[index], carry_oarray[index-1]);
	end
endgenerate
assign carryout = carry_oarray[31];
wire abxor, abcoutxor;
`XOR xor1(abxor, A[31], B[31]);
`XOR xor2(abcoutxor, carryout, abxor);
`XOR xor3(over_flow, addo[31], abcoutxor);
//`XOR or0(over_flow, addo[31], carryout, A[31], B[31]);

endmodule 

module slt(sum, overflow, slto);
//Outputs a single bit (1 if input a is less than input b)
input[31:0] sum;
input overflow;
output slto;
//Taking xor of overflow and most significant bit of sum from the 32bit adder
//If less than, the msb will be 1, unless there's overflow, in which case the msb will be 0
`XOR slt_xor(slto, sum[31], overflow);
endmodule

module structuralMultiplexer(out, mux_command, ando, oro, xoro, addo, slto);
//Takes in the outputs of the operations and an address which chooses the operation actually desired
//outputs only the result of the desired operation
output[31:0] out;
input[2:0] mux_command; //found this from the LUT
input[31:0] ando; //AND/NOR
input[31:0] oro; //OR/NAND
input[31:0] xoro; //XOR
input[31:0] addo; //ADD/SUB
input slto; //SLT, if we're selecting this one, the output will be 32 bits of all 1s or all 0s

wire[2:0] inv_command;
wire[31:0] enableand, enableor, enablexor, enableadd; //depending on mux_command, only one should have a value
wire enableslt; //same here, but slt is one bit only

`NOT notCommand0(inv_command[0], mux_command[0]); //inverting the mux_command so we can do ANDs to determine whether operations are enabled
`NOT notCommand1(inv_command[1], mux_command[1]);
`NOT notCommand2(inv_command[2], mux_command[2]);

`AND slt_and(enableslt, slto, inv_command[2], mux_command[1], inv_command[0]);

//Generate loop to enable each bit and compare
generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: muxgen 
		`AND ando_and(enableand[index], ando[index], inv_command[2], mux_command[1], mux_command[0]); //AND/NOR
		`AND oro_and(enableor[index], oro[index], mux_command[2], inv_command[1], inv_command[0]); //OR/NAND
		`AND xoro_and(enablexor[index], xoro[index], inv_command[2], inv_command[1], mux_command[0]); //XOR
		`AND addo_and(enableadd[index], addo[index], inv_command[2], inv_command[1], inv_command[0]); //ADD/SUB
		`OR or1(out[index], enableand[index],  enableor[index], enablexor[index], enableadd[index], enableslt); //ORs all results so we get the output we want
		
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
	`XORop: begin mux_command = 3'b001; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 1; end //XOR doesn't need anything special;
	`SLTop: begin mux_command = 3'b010; a_inv = 0; b_inv = 1; carry_in = 1; allow_overflow = 0; end //SLT behaves like subtract, but does not allow overflow
	`ANDop: begin mux_command = 3'b011; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 1; end //AND doesn't need anything special
	`NORop: begin mux_command = 3'b011; a_inv = 1; b_inv = 1; carry_in = 0; allow_overflow = 1; end //NOR is just AND with inverse inputs
	`ORop: begin mux_command = 3'b100; a_inv = 0; b_inv = 0; carry_in = 0; allow_overflow = 1; end //OR doesn't need any special inputs
	`NANDop: begin mux_command = 3'b100; a_inv = 1; b_inv = 1; carry_in = 0; allow_overflow = 1; end //NAND is just OR with inverse inputs
default: $display("Please check inputs");
endcase
end
endmodule
module ALU(a, b, addr, out, carry_out, over_flow, zero);
input[31:0] a, b;
input[2:0] addr; //TO-DO SHORTEN TO 2 BITS IF NECESSARY
output[31:0] out;
output carry_out, over_flow, zero;
wire carry_in, b_inv; //determines between ADD/SUB
wire a_inv, allow_overflow; //a_inv determines between NAND/NOR, allow_overflow is needed SLT
wire[2:0] mux_command;
wire[31:0] A, B; //xor with inv_a, inv_b
wire[31:0] addo, xoro, ando, oro;
wire slto;
//Calls the look up table with the command given 
LUT lookuptable(mux_command, a_inv, b_inv, carry_in, allow_overflow, addr);

//If inv_a and/or inv_b
generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: abinv_gen
		`XOR a_invgen(A[index], a[index], a_inv); //in0 is AND/NOR
		`XOR b_invgen(B[index], b[index], b_inv); //in1 is OR/NAND
	end
endgenerate

//Calculates all outputs from our operations, uses these as inputs to our mux
andgate and_gate(A, B, ando); //AND/NOR
orgate or_gate(A, B, oro); //OR/NAND
xorgate xor_gate(A, B, xoro); //XOR
adder32Bit add_gate(addo, carry_out, over_flow, A, B, carry_in); //ADD/SUB, if b_inv, then we're doing subtract
slt slt_gate(addo, over_flow, slto);
`AND allowoverflow_and(overflow, over_flow, allow_overflow);

//Calls MUX with what we've done with logic
structuralMultiplexer mux_structure(out, mux_command, ando, oro, xoro, addo, slto);

wire[31:0] equal;

generate //Checks each index of the sum answer if it is zero, the equal wire at that index is set to 1
genvar index1;
for (index1 = 0; index1 <32; index1 = index1+1)begin
                `NOR nor1(equal[index1], out[index1], 0);
end
endgenerate

//ANDs all of the values in the equal wire to make sure that the original sum here was 0, if so will return 1, if not will return 0
`AND and1(zero, equal[0], equal[1], equal[2], equal[3],equal[4],equal[5],equal[6],equal[7],equal[8],equal[9],equal[10],equal[11],equal[12],equal[13],equal[14],equal[15],equal[16],equal[17],equal[18],equal[19],equal[20],equal[21],equal[22],equal[23],equal[24],equal[25],equal[26],equal[27],equal[28],equal[29],equal[30],equal[31]);
endmodule
module ALU_testbench;
reg[2:0] addr;
reg[31:0] a, b;
wire[31:0] out;
wire carry_out, over_flow, zero;
ALU alu1(a, b, addr, out, carry_out, over_flow, zero);

initial begin
$display("Testing AND");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
addr=`ANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`ANDop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 1's test
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111111", a, b, out, zero);
addr=`ANDop;a=32'b10101010101010101010101010101111;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000101", a, b, out, zero);

$display("/n");
$display("Testing OR");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
addr=`ORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`ORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 1's test
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111111", a, b, out, zero);
addr=`ORop;a=32'b10101010101010101010101010101111;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111111", a, b, out, zero);


$display("/n");
$display("Testing NAND");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
addr=`NANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111111", a, b, out, zero);
addr=`NANDop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 1's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`NANDop;a=32'b10101010101010101010101010101111;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111010", a, b, out, zero);


$display("/n");
$display("Testing NOR");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
addr=`NORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111111", a, b, out, zero);
addr=`NORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 1's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`NORop;a=32'b10101010101010101010101010101111;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);


$display("/n");
$display("Testing XOR");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
addr=`XORop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`XORop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 1's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", a, b, out, zero);
addr=`XORop;a=32'b10101010101010101010101010101111;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b    | %b  |  11111111111111111111111111111010", a, b, out, zero);

$display("These tests have positive addends and don't have overflow");
$display("/n");
$display("Testing ADD");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`ADDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000  //all 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b00111111111111111111111111111111;b=32'b00111111111111111111111111111111; #10000  //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  01111111111111111111111111111110", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b00000000111111110000000011111111;b=32'b00000000000000000000000011111111; #10000 //mixed test
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000111111110000000111111110", a, b, out, over_flow, carry_out, zero);

$display("These tests have positive addends and have overflow");

$display("/n");
$display("Testing ADD");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`ADDop;a=32'b01111111111111111111111111111111;b=32'b01111111111111111111111111111111; #10000 //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  11111111111111111111111111111110", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01110000000000000000000000000000;b=32'b01100000000000000000000000000000; #10000 //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  11010000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01010101010101010101010101010101;b=32'b01110101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  11001010101010101010101010101010", a, b, out, over_flow, carry_out, zero);



$display("These tests have two negative addends without overflow.");
$display("/n");
$display("Testing ADD");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`ADDop;a=32'b11000000000000000000000000000000;b=32'b11000000000000000000000000000000; #10000 //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  10000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b11111111111111111101100011110000;b=32'b11111111111111111111111100000110; #10000 //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  11111111111111111101011111110110", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b11111111111111111111111111111110;b=32'b11111111111111111111111111111110; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  11111111111111111111111111111100", a, b, out, over_flow, carry_out, zero);

$display("These tests have two negative addends with overflow.");
$display("/n");
$display("Testing ADD");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`ADDop;a=32'b10000000111111110000000000000000;b=32'b10000000000000000000000000000000; #10000 //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  000000001111111100000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10011111111111111111111111111111;b=32'b11011111111111111111111111111111; #10000 //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  011111111111111111111111111111110", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b10000000000000000000000000000000;b=32'b10000000000000000001111100000000; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  000000000000000000001111100000000", a, b, out, over_flow, carry_out, zero);


$display("These tests have a positive and negative addends with no overflow");
$display("/n");
$display("Testing ADD");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`ADDop;a=32'b01111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  01111111111111111111111111111110", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01110000000000000000000000000000;b=32'b11100000000000000000000000000000; #10000 //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  01010000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`ADDop;a=32'b01010101010101010101010101010101;b=32'b11110101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  01001010101010101010101010101010", a, b, out, over_flow, carry_out, zero);


$display("These tests are subtraction, with two positive terms without overflow");
$display("/n");
$display("Testing SUB");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`SUBop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000  //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);  
addr=`SUBop;a=32'b00101010101010101010101010101010;b=32'b01010101010101010101010101010101; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  11010101010101010101010101010110", a, b, out, over_flow, carry_out, zero); 
addr=`SUBop;a=32'b00000000111111110000000011111111;b=32'b00000000000000000000000011111111; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000111111110000000000000000", a, b, out, over_flow, carry_out, zero);


$display("Tests subtraction with two negative terms without overflow.");
$display("/n");
$display("Testing SUB");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`SUBop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //mostly 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`SUBop;a=32'b11111111111111111111111000000000;b=32'b10001111111111111111111000000000; #10000 //mostly 1's test
$display("%b  %b |  %b  | %b  | %b | %b  |  01110000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`SUBop;a=32'b11111100000000000011111000000000;b=32'b10111111100000000000000000000011; #10000 //mixed
$display("%b  %b |  %b  | %b  | %b | %b  |  00111100100000000011110111111101", a, b, out, over_flow, carry_out, zero);

$display("These tests are subtraction with one positive and one negative number without overflow.");
$display("/n");
$display("Testing SUB");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`SUBop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);  //all zeros
addr=`SUBop;a=32'b01111111111111111111111100000000;b=32'b11111111111111111111111111111110; #10000 
$display("%b  %b |  %b  | %b  | %b | %b  |  01111111111111111111111000000101", a, b, out, over_flow, carry_out, zero); //almost all 1's.
addr=`SUBop;a=32'b00000000000000000000000000001111;b=32'b11111111111111111111111111111110; #10000 
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000010001", a, b, out, over_flow, carry_out, zero); //mixed

$display("These tests are subtraction with one positive and one negative number with overflow.");
$display("/n");
$display("Testing SUB");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`SUBop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero); //mostly 0's test
addr=`SUBop;a=32'b00101010101010101010101010101010;b=32'b11111111111111111111111111111111; #10000 
$display("%b  %b |  %b  | %b  | %b | %b  |  00101010101010101010101010101011", a, b, out, over_flow, carry_out, zero); //mostly 1's test
addr=`SUBop;a=32'b00000000111111110000000011111111;b=32'b11111111111000000000000011111111; #10000 
$display("%b  %b |  %b  | %b  | %b | %b  |  00000001000111110000000000000000", a, b, out, over_flow, carry_out, zero); //mixed


$display("These tests test the SLT function.");
$display("A                                 B                                |  Out                               | OF | CO|zero|  Expected");
addr=`SLTop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 //equal case
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00011111000000000000000000000000;b=32'b00011111000000000000000000000000; #10000 //equal case
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00000000000000000000000000000111;b=32'b00000000000000000000000000000000; #10000 //num vs. zero
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);
addr=`SLTop;a=32'b11110000000000000000000000000000;b=32'b00000000000000000000000000000111; #10000 //greater than
$display("%b  %b |  %b  | %b  | %b | %b  |  11111111111111111111111111111111", a, b, out, over_flow, carry_out, zero);
addr=`SLTop;a=32'b00000000000000000000000000000111;b=32'b11110000000000000000000000000000; #10000 //less than
$display("%b  %b |  %b  | %b  | %b | %b  |  00000000000000000000000000000000", a, b, out, over_flow, carry_out, zero);


end
endmodule
