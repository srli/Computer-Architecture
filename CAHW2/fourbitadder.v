// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR xor #50

module structuralFullAdder(sum, carryout, a, b, carryin);
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

module FullAdder4bit(sum, carryout, overflow, a, b);
output[3:0] sum; //2s complement sum of a and b
output carryout; //carry out of summation of a and b
output overflow; //true if the calculation resulted in an overflow

input[3:0] a; //First operand in 2s complement format
input[3:0] b; //Second operant in 2s complement format

wire c0, c1, c2;
wire cin = 0;

structuralFullAdder adder0 (sum[0], c0, a[0], b[0], cin);
structuralFullAdder adder1 (sum[1], c1, a[1], b[1], c0);
structuralFullAdder adder2 (sum[2], c2, a[2], b[2], c1);
structuralFullAdder adder3 (sum[3], carryout, a[3], b[3], c2);

//`NOT invsum3(sum3_inv, sum[3]);
//`NOT invcarryout(carryout_inv, carryout);

//`AND and0(overflow0, sum3_inv, carryout);
//`AND and1(overflow1, sum[3], carryout_inv); //basically making sure we have overflow

//`OR or0(overflow, overflow0, overflow1);

`XOR xor0(overflow, carryout, c2);

 endmodule

module testFullAdder;
//reg a, b, carryin;
//wire sum, carryout;
reg[3:0] a, b;
wire[3:0] sum;
wire carryout, overflow;

FullAdder4bit fouradder (sum, carryout, overflow, a, b);

initial begin
$display("A     B    |  SUM       COUT     OVERFLOW | ESUM EOVERFLOW");
a=4'b0000;b=4'b0000; #1000 //initialize
$display("No Overflow");
a=4'b0001;b=4'b0001; #1000 
$display("%b  %b |  %b      %b        %b        | 0010 0", a, b, sum, carryout, overflow);
a=4'b0010;b=4'b0100; #1000 
$display("%b  %b |  %b      %b        %b        | 0110 0", a, b, sum, carryout, overflow);
a=4'b1110;b=4'b1100; #1000 
$display("%b  %b |  %b      %b        %b        | 1010 0", a, b, sum, carryout, overflow);
a=4'b1111;b=4'b1101; #1000
$display("%b  %b |  %b      %b        %b        | 1100 0", a, b, sum, carryout, overflow);
a=4'b0010;b=4'b1100; #1000
$display("%b  %b |  %b      %b        %b        | 1110 0", a, b, sum, carryout, overflow);
a=4'b0010;b=4'b1110; #1000 
$display("%b  %b |  %b      %b        %b        | 0000 0", a, b, sum, carryout, overflow);
$display("Overflow");
a=4'b0100;b=4'b0110; #1000 
$display("%b  %b |  %b      %b        %b        | 1010 1", a, b, sum, carryout, overflow);
a=4'b0010;b=4'b0110; #1000
$display("%b  %b |  %b      %b        %b        | 1000 1", a, b, sum, carryout, overflow);
a=4'b0011;b=4'b0110; #1000 
$display("%b  %b |  %b      %b        %b        | 1001 1", a, b, sum, carryout, overflow);
a=4'b1010;b=4'b1101; #1000
$display("%b  %b |  %b      %b        %b        | 0111 1", a, b, sum, carryout, overflow);
a=4'b1010;b=4'b1100; #1000
$display("%b  %b |  %b      %b        %b        | 0110 1", a, b, sum, carryout, overflow);
a=4'b1011;b=4'b1001; #1000
$display("%b  %b |  %b      %b        %b        | 0100 1", a, b, sum, carryout, overflow);



end
endmodule
	