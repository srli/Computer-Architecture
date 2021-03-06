module testxor(out, a, b);
input[31:0] a, b;
output[31:0] out;

generate
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: xorgen
//		`NOT nota(a_inv[index], a[index]);
//		`NOT notb(b_inv[index], b[index]);
//		`AND anda(andaout[index], a_inv[index], b[index]);
//		`AND andb(andbout[index], a[index], b_inv[index]);
//		`OR orab(out[index], andaout[index], andbout[index]);
		xor xor1(out[index], a[index], b[index]);
	end
endgenerate
endmodule

module testxorbench;
reg[31:0] a, b;
wire[31:0] out;

testxor xor1(out, a, b);

initial begin
$display("a    |b      |out");
a=32'b00000000000000000000000000000000;b=32'b00000000000000000000000000000000; #10000 
$display("%b   |%b     |%b", a, b, out);
a=32'b11111111111111111111111111111111;b=32'b11111111111111111111111111111111; #10000 //all 0's test
$display("%b   |%b     |%b", a, b, out);

end
endmodule