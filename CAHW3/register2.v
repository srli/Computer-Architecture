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

//module mux32to1by32(out, address, inputs);
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
endmodule


module decoder1to32(out, enable, address);
output[31:0] out;
input enable;
input[4:0] address;
assign out = enable<<address; //left shifts the enable bit however many bits the address declares
endmodule

module regfile(ReadData1, // Contents of first register read  //WORKED WITH LINDSEY ON THIS ONE
 ReadData2, // Contents of second register read
 WriteData, // Contents to write to register
 ReadRegister1, // Address of first register to read 
 ReadRegister2, // Address of second register to read
 WriteRegister, // Address of register to write
 RegWrite, // Enable writing of register when High
 Clk); // Clock (Positive Edge Triggered)

output[31:0] ReadData1, ReadData2;
input[4:0] ReadRegister1, ReadRegister2; //addresses of the two registers
input[31:0] WriteData; //0 or 1
input[4:0] WriteRegister; //address of the write
input RegWrite, Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];

decoder1to32 decoder1(decoderout, RegWrite, WriteRegister);
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
//mux32to1by32 data1 (ReadData1, ReadRegister1, register);
//mux32to1by32 data2 (ReadData2, ReadRegister2, register);

endmodule

module test;
	
reg d, wrenable, clk;
wire q;
register reg1test(q, d, wrenable, clk);
initial begin
$display("D  | ENABLE  |  CLK  |   Q  ");
clk=1;wrenable=1;d=1; #5000
$display("%b  |%b  |%b  |%b  ", d, wrenable, clk, q);
clk=1;wrenable=1;d=0; #5000
$display("%b  |%b  |%b  |%b  ", d, wrenable, clk, q);
clk=0;wrenable=1;d=1; #5000
$display("%b  |%b  |%b  |%b  ", d, wrenable, clk, q);
clk=1;wrenable=1;d=0; #5000
$display("%b  |%b  |%b  |%b  ", d, wrenable, clk, q);
clk=0;wrenable=1;d=1; #5000
$display("%b  |%b  |%b  |%b  ", d, wrenable, clk, q);
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
clk=1;wrenable=1;d=32'b00000000000000000000000000000000; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
clk=0;wrenable=1;d=32'b11111111111111111111111111111111; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
clk=1;wrenable=1;d=32'b00000000000000000000111111111111; #10000 //all 0's test
$display("%b  %b |  %b    | %b  |  00000000000000000000000000000000", clk, wrenable, d, q);
end

endmodule

module testregisterfile;
reg[31:0] WriteData;
reg[4:0] ReadRegister1, ReadRegister2, WriteRegister;
reg RegWrite, Clk;

wire[31:0] ReadData1, ReadData2;
wire perfect, broken_write, broken_decoder, bad_zero, bad_17;


regfile perfectreg (ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);
//WriteData=32'b11111111111111111111111111111111;WriteRegister=5'b00001;ReadRegister1=5'b00001;ReadRegister2=5'b00010;
//Clk=0;RegWrite=1; #10
//WriteData=32'b11111111111111111111111111111111;WriteRegister=5'b00001;ReadRegister1=5'b00001;ReadRegister2=5'b00010;
//Clk=1;RegWrite=1; #10
//
//assert (WriteData==ReadData1) $display("Equal");

initial begin
#50
Clk=0; #5
Clk=1; #5
WriteData=32'b11111111111111111111111111111111;WriteRegister=5'b00001;ReadRegister1=5'b00001;ReadRegister2=5'b00010;
RegWrite=1; #10
$display("Perfect Register File? %d", ReadData1);
//$display("Broken Write Enable? %d", broken_write);
//$display("Broken Decoder? %d", broken_decoder);
//$display("Bad Register Zero? %d", bad_zero);
//$display("Broken Port 17? %d", bad_17);

end

endmodule

module regfile(ReadData1, ReadData2, WriteData, ReadRegister1, ReadRegister2, WriteRegister, RegWrite, Clk);

output[31:0]	ReadData1;
output[31:0]	ReadData2;
input[31:0]	WriteData;
input[4:0]	ReadRegister1;
input[4:0]	ReadRegister2;
input[4:0]	WriteRegister;
input		RegWrite;
input		Clk;

wire[31:0] decoderout;
wire[31:0] register[31:0];

decoder1to32 decoder1(decoderout, RegWrite, WriteRegister);
register32zero reg32bit0 (register[0], WriteData, decoderout[0], clk);
generate
genvar index;
for (index = 1; index<32; index = index + 1)
	begin: regen
		register32 reg32bit (register[index], WriteData, decoderout[index], clk);
	end
endgenerate

mux32to1by32 data1 (ReadData1, ReadRegister1, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);
mux32to1by32 data2 (ReadData2, ReadRegister2, register[0], register[1], register[2], register[3], register[4], register[5], register[6], register[7], register[8], register[9], register[10], register[11], register[12], register[13], register[14], register[15], register[16], register[17], register[18], register[19], register[20], register[21], register[22], register[23], register[24], register[25], register[26], register[27], register[28], register[29], register[30], register[31]);


// These two lines are clearly wrong.  They are included to showcase how the test harness works.
// Delete them after you understand the process, and replace them with actual code.

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
regfile DUT(ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);

// The test harness to test the DUT
hw4testbench tester(begintest, endtest, dutpassed,ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);


initial begin
begintest=0;
#10;
begintest=1;
#1000;
end

always @(posedge endtest) begin
$display(dutpassed);
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
output reg dutpassed;
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

// Test Case 1: Write to 42 register 2, verify with Read Ports 1 and 2
// This will pass because the example register file is hardwired to always return 42.
WriteRegister = 2;
WriteData = 42;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;	// Generate Clock Edge
if(ReadData1 != 42 || ReadData2!= 42) begin
	dutpassed = 0;
	$display("Test Case 1 Failed");
	end else begin
	$display("Test Case 1 Success");
	end

// Test Case 2: Write to 15 register 2, verify with Read Ports 1 and 2
// This will fail with the example register file, but should pass with yours.
WriteRegister = 2;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;
if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed");
	end else begin
	$display("Test Case 2 Success");
	end

//We're done!  Wait a moment and signal completion.
#5
endtest = 1;
end

endmodule