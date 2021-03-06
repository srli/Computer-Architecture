module register(q, d, wrenable, clk); //FOR DRAWING THIS, using a DFF at the heart of the circuit
input d;
input wrenable;
input clk;
output reg q;
always @(posedge clk) begin
	if(wrenable) begin
	q = d;
	end
end
endmodule

module register32(q, d, wrenable, clk);
input[31:0] d;
input wrenable;
input clk;
output reg[31:0] q;

always @(posedge clk) begin
	if(wrenable) begin
	q = d;
	end
end
endmodule

module register32zero(q, d, wrenable, clk);
input[31:0] d;
input wrenable;
input clk;
output wire[31:0] q;

assign q=32'b0;

//wire zeroenable;
//
//and and1(zeroenable, wrenable, 0);
//
//always @(posedge clk) begin
//	if(wrenable) begin
//	q = d;
//	end
//end
endmodule

module mux32to1by1(out, address, inputs);
input[31:0] inputs;
input[4:0] address;
output out;
assign out = inputs[address];
endmodule

module mux32to1by32(out, address, input0, input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12, input13, input14, input15, input16, input17, input18, input19, input20, input21, input22, input23, input24, input25, input26, input27, input28, input29, input30, input31);
input[31:0] input0, input1, input2, input3, input4, input5, input6, input7, input8, input9, input10, input11, input12, input13, input14, input15, input16, input17, input18, input19, input20, input21, input22, input23, input24, input25, input26, input27, input28, input29, input30, input31;
input[4:0] address;
output[31:0] out;
wire[31:0] mux[31:0]; // Creates a 2d Array of wires

assign mux[0] = input0; // Connects the sources of the array
assign mux[1] = input1;
assign mux[2] = input2;
assign mux[3] = input3;
assign mux[4] = input4;
assign mux[5] = input5;
assign mux[6] = input6;
assign mux[7] = input7;
assign mux[8] = input8;
assign mux[9] = input9;
assign mux[10] = input10;
assign mux[11] = input11;
assign mux[12] = input12;
assign mux[13] = input13;
assign mux[14] = input14;
assign mux[15] = input15;
assign mux[16] = input16;
assign mux[17] = input17;
assign mux[18] = input18;
assign mux[19] = input19;
assign mux[20] = input20;
assign mux[21] = input21;
assign mux[22] = input22;
assign mux[23] = input23;
assign mux[24] = input24;
assign mux[25] = input25;
assign mux[26] = input26;
assign mux[27] = input27;
assign mux[28] = input28;
assign mux[29] = input29;
assign mux[30] = input30;
assign mux[31] = input31;
assign out=mux[address]; // Connects the output of the array
initial begin
#50
$display("mux32to1 out %b", out);
end
endmodule


module decoder1to32(out, enable, address);
output[31:0] out;
input enable;
input[4:0] address;
assign out = enable<<address; //left shifts the enable bit however many bits the address declares
endmodule

//WORKED WITH LINDSEY ON REGFILE
module perfect_regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];

decoder1to32 decoder1(decoderout, RegWrite, WriteRegister);
register32zero reg32bit0 (register[0], WriteData, decoderout[0], Clk);
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 1; index<32; index = index + 1)
	begin
		register32 reg32bit (register[index], WriteData, decoderout[index], Clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1, ReadRegister1, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ReadRegister2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);

initial begin
end

endmodule


module writeenable_regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];
wire always_enabled;

or or1(always_enabled, RegWrite, 1);

decoder1to32 decoder1(decoderout, always_enabled, WriteRegister);
register32zero reg32bit0 (register[0], WriteData, decoderout[0], clk);
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 1; index<32; index = index + 1)
	begin: regen
		register32 reg32bit (register[index], WriteData, decoderout[index], clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1, ReadRegister1, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ReadRegister2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
endmodule

module decoder_regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];

decoder1to32 decoder1(decoderout, always_enabled, WriteRegister);
assign decoderout=32'b11111111111111111111111111111111;
register32zero reg32bit0 (register[0], WriteData, decoderout[0], clk);
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 1; index<32; index = index + 1)
	begin: regen
		register32 reg32bit (register[index], WriteData, decoderout[index], clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1, ReadRegister1, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ReadRegister2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
endmodule



module zero_regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];

decoder1to32 decoder1(decoderout, always_enabled, WriteRegister);
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 0; index<32; index = index + 1)
	begin: regen
		register32 reg32bit (register[index], WriteData, decoderout[index], clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1, ReadRegister1, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ReadRegister2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
endmodule

module port2_regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

reg[4:0] ModifiedRead1, ModifiedRead2;
wire[31:0] decoderout;
wire[31:0] register[31:0];

always @(ReadRegister1)
if(ReadRegister1 == 2) begin
	ModifiedRead1 = 17;
	end
	else begin
	ModifiedRead1 = ReadRegister1;
	end

always @(ReadRegister2)
if(ReadRegister2 == 2) begin
	ModifiedRead2 = 17;
	end
	else begin
	ModifiedRead2 = ReadRegister2;
	end

decoder1to32 decoder1(decoderout, RegWrite, WriteRegister);
register32zero reg32bit0 (register[0], WriteData, decoderout[0], clk);
generate //Use generate to create an xor gate to check every bit
genvar index;
for (index = 1; index<32; index = index + 1)
	begin: regen
		register32 reg32bit (register[index], WriteData, decoderout[index], clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1,  ModifiedRead1,  register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ModifiedRead2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
endmodule

module hw4testbenchharness;
wire[31:0]	ReadData1;
wire[31:0]	ReadData2;
wire[31:0]	WriteData;
wire[4:0]	ReadRegister1;
wire[4:0]	ReadRegister2;
wire[4:0]	WriteRegister;
wire		RegWrite;
wire		Clk;
reg		begintest;

// The register file being tested.  DUT = Device Under Test
//perfect_regfile DUT(ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
writeenable_regfile DUT(ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
//decoder_regfile DUT(ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
//port2_regfile DUT(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
//zero_regfile DUT(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);

// The test harness to test the DUT
hw4testbench tester(begintest, endtest, dutpassed,ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);


initial begin
begintest=0;
#10;
begintest=1;
#1000;
end

always @(posedge endtest) begin
$display("DUT Passed? %b", dutpassed);
end

endmodule

// This is your actual test bench.
// It generates the signals to drive a registerfile and passes it back up one layer to the harness
//	((This lets us plug in various working / broken registerfiles to test
// When begintest is asserted, begin testing the register file.
// When your test is conclusive, set dutpassed as appropriate and then raise endtest.
module hw4testbench(begintest, endtest, dutpassed,
		    ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);
output reg endtest;
output reg dutpassed; //enable_b, decoder_b, zero_b, port2_b;
input	   begintest;

input[31:0]		ReadData1;
input[31:0]		ReadData2;
output reg[31:0]	WriteData;
output reg[4:0]		ReadRegister1;
output reg[4:0]		ReadRegister2;
output reg[4:0]		WriteRegister;
output reg		RegWrite;
output reg		Clk;

initial begin
WriteData=0;
ReadRegister1=0;
ReadRegister2=0;
WriteRegister=0;
RegWrite=0;
Clk=0;
end

always @(posedge begintest) begin
endtest = 0;
dutpassed = 1;
#10

// Test Case 1: Write to 42 register 2, verify with both read ports at 2
//Simply tests to see if general read/write is working
WriteRegister = 2;
WriteData = 42;
RegWrite = 1;
ReadRegister1 = 0;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;
#5 Clk=1; #5 Clk=0;		// Generate Clock Edge
$display("reg1 %b, reg2 %b, writedata %b", ReadData1, ReadData2, WriteData);
if(ReadData1 != 42 || ReadData2 != 42) begin
	dutpassed = 0;
	$display("Basic read/write failed.");
	end

//// Test Case 2: Write to 15 register 2, but write enable is off.
//// ReadRegister shouldnt' return anything because write enable is 0. If returns, then writenable is broken
//WriteRegister = 3;
//WriteData = 15;
//RegWrite = 0;
//ReadRegister1 = 3;
//ReadRegister2 = 3;
//#5 Clk=1; #5 Clk=0;
////$display("reg1 %b, reg2 %b", ReadData1, ReadData2);
//if(ReadData1 != 0 || ReadData2!= 0) begin
//	dutpassed = 0;	// On Failure, set to false.
//	$display("Write enable is broken");
//	end

//We're done!  Wait a moment and signal completion.
#5
endtest = 1;
end

endmodule

module test32;
reg[31:0] d;
reg wrenable;
reg clk;
wire[31:0] q;

register32 reg32bittest(q, d, wrenable, clk);

initial begin
$display("Testing AND");
$display("A                                 B                                |  Out                                 |Zero|  Expected");
#5 clk=1; #5 clk = 0;
wrenable=1;d=42; #100 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
#5 clk=1; #5 clk = 0;
wrenable=1;d=30; #100 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
#5 clk=1; #5 clk = 0;
wrenable=1;d=12; #100 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
end

endmodule