`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    10:23:28 09/25/2014 
// Design Name: 
// Module Name:    mp0 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////

`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR or #50

module mp0(input [7:0] sw, output [7:0] led);
// Input A is the first 4 switches - sw[0:3]
// Input B is the second 4 switches - sw[4:7]
// The sum is displayed on the first 4 LEDs - led[3:0]
// The carry out is the 5th LED - led[4]
// The overflow detect is shown on the last LED - led[7]
 FullAdder4bit adder(led[3:0],led[4],led[7],sw[3:0],sw[7:4]);endmodule

module structuralFullAdder(sum, carryout, a, b, carryin);

output sum, carryout;
input a, b, carryin;

//sets up wires for inverse of inputs
wire na;
wire nb;
wire nc;

//creates inverse for each of the inputs
`NOT ainv(na, a);
`NOT binv(nb, b);
`NOT cinv(nc, carryin);


//sets up variables and gates needed for the carryout
`AND and1(ab, a, b);
`AND and2(ac, a, carryin);
`AND and3(nabc, na, b, carryin);
`AND and4(nanbc, na, nb, carryin);
`AND and5(nabnc, na, b, nc);
`AND and6(anbnc, a, nb, nc);

//or gate which creates carryout
`OR csumoutput(carryout, ab, ac, nabc);

//sets up gates for the sum output
`AND and7(abc, a, b, carryin);

//actually creates sum output
`OR sumoutput(sum, abc, anbnc, nanbc, nabnc);
endmodule


module FullAdder4bit(sum,carryout,overflow,a,b);
output[3:0] sum; // 2?s complement sum of a and b
output carryout; // Carry out of the summation of a and b
output overflow; // True if the calculation resulted in an overflow
input[3:0] a; // First operand in 2?s complement format
input[3:0] b; // Second operand in 2?s complement format
// Your Code Here


wire c0,c1,c2;
wire cin = 0;
wire nsum3, ncarryout;



//Using four FullAdders to create a 4-Bit full adder 
structuralFullAdder adder0 (sum[0], c0, a[0], b[0], cin);
structuralFullAdder adder1 (sum[1], c1, a[1], b[1], c0);
structuralFullAdder adder2 (sum[2], c2, a[2], b[2], c1);
structuralFullAdder adder3 (sum[3], carryout, a[3], b[3], c2); 

`NOT invsum3(nsum3, sum[3]);
`NOT invcarryout(ncarryout, carryout);

`AND and0(overflowpt1, nsum3, carryout); 
`AND and1(overflowpt2, sum[3], ncarryout);

`OR or0(overflow, overflowpt1, overflowpt2);
endmodule


