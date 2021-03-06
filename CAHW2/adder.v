// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50
`define XOR xor #50

module behavioralFullAdder(sum, carryout, a, b, carryin);
output sum, carryout;
input a, b, carryin;
assign {carryout, sum}=a+b+carryin;
endmodule

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

`AND bc(b_c, a, carryin);
`AND ac(a_c, a, carryin);
`AND ab(a_b, a, b);
`OR cout(carryout, b_c, a_c, a_b);

endmodule

module testFullAdder;
reg a, b, carryin;
wire sum, carryout;
//behavioralFullAdder adder (sum, carryout, a, b, carryin);
structuralFullAdder adder (sum, carryout, a, b, carryin);

initial begin
$display("A  B CIN | COUT  SUM | ECOUT  ESUM");
a=0;b=0;carryin=0; #1000
$display("%b  %b  %b  |  %b     %b  | 0      0", a, b, carryin, sum, carryout);
a=0;b=0;carryin=1; #1000
$display("%b  %b  %b  |  %b     %b  | 1      0", a, b, carryin, sum, carryout);
a=0;b=1;carryin=0; #1000
$display("%b  %b  %b  |  %b     %b  | 1      0", a, b, carryin, sum, carryout);
a=0;b=1;carryin=1; #1000
$display("%b  %b  %b  |  %b     %b  | 0      1", a, b, carryin, sum, carryout);
a=1;b=0;carryin=0; #1000
$display("%b  %b  %b  |  %b     %b  | 1      0", a, b, carryin, sum, carryout);
a=1;b=0;carryin=1; #1000
$display("%b  %b  %b  |  %b     %b  | 0      1", a, b, carryin, sum, carryout);
a=1;b=1;carryin=0; #1000
$display("%b  %b  %b  |  %b     %b  | 0      1", a, b, carryin, sum, carryout);
a=1;b=1;carryin=1; #1000
$display("%b  %b  %b  |  %b     %b  | 1      1", a, b, carryin, sum, carryout);

end
endmodule
	