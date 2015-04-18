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
generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: andgen
		`XOR xor1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

//module slt(a, b, zero);
////ADD CODE HERE
//endmodule
//
//module add(a, b, out, carryout, overflow);
////ADD CODE HERE
//endmodule
//
//module sub(a, b, out, carryout, overflow);
////ADD CODE EHRE
//endmodule
//
//
module andgate(a, b, out);
output[31:0] out;
input[31:0] a, b;
generate
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

generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: orgen
		`OR or1(out[index], a[index], b[index]);
	end
endgenerate
endmodule
module nandgate(a, b, out);

output[31:0] out;
input[31:0] a, b;

generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: nandgen
		`NAND nand1(out[index], a[index], b[index]);
	end
endgenerate
endmodule
module norgate(a, b, out);

output[31:0] out;
input[31:0] a, b;

generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: norgen
		`NOR nor1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

module testand; 
wire[31:0] out; // 2?s complement sum of a and b
reg[31:0] a; // First operand in 2?s complement format
reg[31:0] b; // Second operand in 2?s complement format
andgate andgate1 (a, b, out); // Swap after testing

initial begin
$display("Testing AND Gate");//replace with behavioral when testing that
$display("a                                 b                                |  out                                 | Expected");
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //overflow
$display("%b  %b |  %b    | 11111111111111111111111111111111", a, b, out);
a=32'b10000000000000000000000000000000;b=32'b10000000000000000000000000000000; #5000 //overflow
$display("%b  %b |  %b    | 10000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000001;b=32'b00000000000000000000000000000001; #5000 //carryover
$display("%b  %b |  %b    | 0000000000000000000000000000001", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
end
endmodule

module testnor; 
wire[31:0] out; // 2?s complement sum of a and b
reg[31:0] a; // First operand in 2?s complement format
reg[31:0] b; // Second operand in 2?s complement format
norgate norgate (a, b, out); // Swap after testing

initial begin
$display("Testing NOR Gate");//replace with behavioral when testing that
$display("a                                 b                                |  out                                 | Expected");
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //overflow
$display("%b  %b |  %b    | 11111111111111111111111111111111", a, b, out);
a=32'b10000000000000000000000000000000;b=32'b10000000000000000000000000000000; #5000 //overflow
$display("%b  %b |  %b    | 10000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000001;b=32'b00000000000000000000000000000001; #5000 //carryover
$display("%b  %b |  %b    | 0000000000000000000000000000001", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000 
$display("%b  %b |  %b    | 00000000000000000000000000000000", a, b, out);


end
endmodule


module LUT;
reg[3:0] addr;
reg[31:0] a, b, out;
wire[31:0] addo, subo, xoro, slto, ando, nando, noro, oro;
//wire carryout, overflow, zero;

//IMPLEMENT THIS STRUCTURE WITH MUX
andgate andgate1(a, b, ando);
norgate norgate1(a, b, noro);
orgate orgate1(a, b, oro);
nandgate nandgate1(a, b, nando);

//LOOK OVER ERIK CODE AND IMPLEMENT HERE
always @ (addr) begin
case(addr)
`ADDop: begin out = addo; end //ADD CARRYOUT, OVERFLOW
`SUBop: out = subo; //ADD CARRYOUT, OVERFLOW
`XORop: out = xoro;
`SLTop: out = 32'b0; //ADD ZERO OUTPUT HERE
`ANDop: out = ando;
`NANDop: out = nando;
`NORop: out = noro;
`ORop: out = oro;
default: $display("Please check inputs");
endcase
end

initial begin
$display("Testing selects");
$display("a                                 b                                |  out                                 | Expected");
addr=`ANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000
$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
addr=`NANDop;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //overflow
$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
addr=`NANDop;a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #5000
$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
//addr=`NOR;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //overflow
//$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
//addr=`AND;a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #5000 //overflow
//$display("%b  %b |  %b    | 0000000000000000000000000000000", a, b, out);
end
endmodule