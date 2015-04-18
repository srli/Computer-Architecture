// define gates with delays
`define AND and #50
`define OR or #50
`define NOT not #50

module behavioralMultiplexer(out, address0,address1, in0,in1,in2,in3);
output out;
input address0, address1;
input in0, in1, in2, in3;
wire[3:0] inputs = {in3, in2, in1, in0};
wire[1:0] address = {address1, address0};
assign out = inputs[address];
endmodule

module structuralMultiplexer(out, address0,address1, in0,in1,in2,in3);
output out;
input address0, address1;
input in0, in1, in2, in3;

`NOT notaddress0(addr0_inv, address0);
`NOT notaddress1(addr1_inv, address1);

`AND in0_and(in0and, in0, addr0_inv, addr1_inv);
`AND in1_and(in1and, in1, address0, addr1_inv);
`AND in2_and(in2and, in2, addr0_inv, address1);
`AND in3_and(in3and, in3, address0, address1);

`OR input_or(out, in0and, in1and, in2and, in3and);

endmodule

module testMultiplexer;
reg addr0, addr1;
reg in0, in1, in2, in3;
wire out;
//behavioralMultiplexer multiplexer(out,addr0,addr1,in0,in1,in2,in3);
structuralMultiplexer multiplexer(out,addr0,addr1,in0,in1,in2,in3); // Swap after testing

initial begin
$display("A1 A0 | I0 I1 I2 I3 | O | Expected Output");
addr1=0; addr0=0;in0=0; in1=0;in2=0;in3=0; #1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | False", addr1, addr0, in0, in1, in2, in3, out);
addr1=0; addr0=0;in0=1; in1=0;in2=0;in3=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | True", addr1, addr0, in0, in1, in2, in3, out);
addr1=0; addr0=1;in1=0; in0=0;in2=0;in3=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | False", addr1, addr0, in0, in1, in2, in3, out);
addr1=0; addr0=1;in1=1; in0=0;in2=0;in3=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | True", addr1, addr0, in0, in1, in2, in3, out);
addr1=1; addr0=0;in2=0; in1=0;in0=0;in3=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | False", addr1, addr0, in0, in1, in2, in3, out);
addr1=1; addr0=0;in2=1; in1=0;in0=0;in3=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | True", addr1, addr0, in0, in1, in2, in3, out);
addr1=1; addr0=1;in3=0; in1=0;in2=0;in0=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | False", addr1, addr0, in0, in1, in2, in3, out);
addr1=1; addr0=1;in3=1; in1=0;in2=0;in0=0;#1000;
$display("%b  %b  | %b  %b  %b  %b  | %b | True", addr1, addr0, in0, in1, in2, in3, out);
end
endmodule
