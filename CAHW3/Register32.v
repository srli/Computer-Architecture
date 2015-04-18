module register32(q, d, wrenable, clk);
input[31:0] d;
input wrenable;
input clk;
output reg[31:0] q;

//Changes all the q bits to match d
always @(posedge clk) begin
 if(wrenable) begin
q = d;
 end
end
endmodule

module register32zero(q,d,wrenable,clk);
input[31:0] d;
input wrenable;
input clk;

//changes all the q bits to 0
output reg[31:0] q;
always @(posedge clk) begin
 if(wrenable) begin
q = 32'b 0;
 end
end
endmodule
module mux32to1by1(out, address, inputs);
input[31:0] inputs;
input[4:0] address;
output out;

wire[31:0] inputs;
wire out;
assign out = inputs[address]; //single bit output
endmodule
module mux32to1by32(out, address, input0, input1, input2,input3,input4,input5,input6,input7,input8,input9,input10,input11,input12,input13,input14,input15,input16,input17,input18,input19,input20,input21,input22,input23,input24,input25,input26,input27,input28,input29,input30,input31);
input[31:0] input0, input1, input2, input3,input4,input5,input6,input7,input8,input9,input10,input11,input12,input13,input14,input15,input16,input17,input18,input19,input20,input21,input22,input23,input24,input25,input26,input27,input28,input29,input30,input31;
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
assign out = enable<<address; 
endmodule
module regfile(ReadData1, // Contents of first register read
 ReadData2, // Contents of second register read
 WriteData, // Contents to write to register
 ReadRegister1, // Address of first register to read 
 ReadRegister2, // Address of second register to read
 WriteRegister, // Address of register to write
 RegWrite, // Enable writing of register when High
 Clk); // Clock (Positive Edge Triggered)

//Worked with Sophie Li on this module

//setting up inputs and outputs Note which are 32 bit and which are only 5
output[31:0] ReadData1, ReadData2;

input[31:0]  WriteData;
input[4:0]   ReadRegister1, ReadRegister2, WriteRegister;
input 	     RegWrite, Clk;

wire[31:0]   decoderOut;
wire[31:0]   register [31:0];

//Decoder creates enables for all of the registers
decoder1to32 decoder(decoderOut, RegWrite, WriteRegister);
//regardless of input, the first register is 0
register32zero register0(register[0], WriteData, decoderOut[0], Clk); 

//All other registers are either enabled and edited or hold value, based on decoder output
generate
genvar index2;
	for (index2 = 1; index2<32; index2 = index2 + 1) begin
		register32 register1(register[index2], WriteData, decoderOut[index2], Clk);	
	end
endgenerate

//Assigning all of the registers as inputs to the mux
mux32to1by32 mux1(ReadData1, ReadRegister1, register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],register[8],register[9],register[10],register[11],register[12],register[13],register[14],register[15],register[16],register[17],register[18],register[19],register[20],register[21],register[22],register[23],register[24],register[25],register[26],register[27],register[28],register[29],register[30],register[31]);
mux32to1by32 mux2(ReadData2, ReadRegister2, register[0],register[1],register[2],register[3],register[4],register[5],register[6],register[7],register[8],register[9],register[10],register[11],register[12],register[13],register[14],register[15],register[16],register[17],register[18],register[19],register[20],register[21],register[22],register[23],register[24],register[25],register[26],register[27],register[28],register[29],register[30],register[31]);
endmodule
module hw4testbenchharness;
// Validates your hw4testbench by connecting it to various functional 
// or broken register files and verifying that it correctly identifies

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
hw4testbench tester(begintest, endtest, dutpassed, ReadData1,ReadData2,WriteData, ReadRegister1, ReadRegister2,WriteRegister,RegWrite, Clk);


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
//Test for Case 1:

// Test Case 1a: Write to 42 register 2, verify with Read Ports 1 and 2
WriteRegister = 2;
WriteData = 42;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;	// Generate Clock Edge
if(ReadData1 != 42 || ReadData2!= 42) begin
	dutpassed = 0;
	$display("Test Case 1 Failed -Imperfect Register");
	end

// Test Case 1b: Write to 15 register 7, verify with Read Ports 1 and 2 (using 2 cases
//reduces the liklihood of one of the read ports only reading a certain register
WriteRegister = 7;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 7;
ReadRegister2 = 7;
#5 Clk=1; #5 Clk=0;

if(ReadData1 != 15 || ReadData2!= 15) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test Case 2 Failed -Imperfect register");
	end




// Test for Case 2: verify that write enable works
//Writes '5' to register 2 and then 3 and then passes in 7 to register 3 with the 'write' endable set to 0
// verifies whether the value in register is the same 

//Write 5 to reg2
WriteRegister = 2;
WriteData = 5;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

//Write 5 to reg 3
WriteRegister = 3;
WriteData = 5;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

//read registers 2&3, pass in 7 to reg 2 without write enabled
WriteRegister = 2;
WriteData = 7;
RegWrite = 0;
ReadRegister1 = 2;
ReadRegister2 = 3;
#5 Clk=1; #5 Clk=0;

if(ReadData1 != ReadData2) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test for Case 2 Failed: Write-enable ignored");
	end



// Test for Case 3 Writes one value to register 1 then a different value to register 2, checks to see that theese 
//two values are the same, if different assumes that the decoder is broken

//Write 5 to reg 3
WriteRegister = 3;
WriteData = 5;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

//read registers 2&3, pass in 7 to reg 2
WriteRegister = 2;
WriteData = 7;
RegWrite = 1;
ReadRegister1 = 2;
ReadRegister2 = 3;
#5 Clk=1; #5 Clk=0;

if(ReadData1 == ReadData2) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test for Case 3 Failed: Decoder broken");
	end



// Test for Case 4: verify that register zero cannot be written to
//Attempts to write '5' to register 0 and then verifies the register result
WriteRegister = 0;
WriteData = 5;
RegWrite = 1;
ReadRegister1 = 0;
ReadRegister2 = 0;
#5 Clk=1; #5 Clk=0;

if(ReadData1 != 0 || ReadData2!= 0) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test for Case 4 Failed: Zero Register can hold a non-zero value");
	end



//Test for Case 5: Write 17 to register 17 and 15 to register 2, 
//read register 17 with port 1 and register 2 with port 2. Verify that they are different

//Write to 17 first to make sure there is data there
WriteRegister = 17;
WriteData = 17;
RegWrite = 1;
ReadRegister1 = 17;
ReadRegister2 = 17;
#5 Clk=1; #5 Clk=0;

//Write to 2 and compare the readData outputs
WriteRegister = 2;
WriteData = 15;
RegWrite = 1;
ReadRegister1 = 17;
ReadRegister2 = 2;
#5 Clk=1; #5 Clk=0;

if(ReadData1 == ReadData2) begin
	dutpassed = 0;	// On Failure, set to false.
	$display("Test for Case 5 Failed: ReadRegister2 only reads register 17");
	end

//We're done!  Wait a moment and signal completion.
#5
if(dutpassed == 1) begin
	$display("All Tests passed, register file is good");
end
endtest = 1;
end
endmodule
