// define gates with delays
`define AND and #10
`define OR or #10
`define NOT not #10
`define XOR xor #10

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


module test32BitAdder;
reg[31:0] a, b;
reg ci;
wire[31:0] sum;

wire Cout, overflow;

add32Bit add32Bit(sum,Cout,overflow,a,b, ci);

initial begin
a =32'b01110111011101110111011101110111; b = 32'b10111011101110111011101110111011; ci = 0; #100000000
$display("%b  %b   %b  %b  %b", a, b, sum, Cout, overflow);
end
endmodule
