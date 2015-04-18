//module datamemory(clk, dataOut, address, writeEnable, dataIn);
module datamemory(dataOut, dataIn, addressr, clk, writeEnable);
parameter addresswidth = 8;
parameter depth = 2**addresswidth;
parameter width = 8;

output reg [width-1:0]  dataOut;
wire[7:0] tempreg1;

input clk;
input [addresswidth-1:0]    addressr;
input writeEnable;
input[width-1:0]    dataIn;

reg [width-1:0] memory [depth-1:0];
wire[6:0] address;
assign address = addressr[7:1];

always @(posedge clk) begin
    if(writeEnable)
        memory[address] <= dataIn;
     	dataOut <= memory[address];
     end

assign tempreg1 = memory[0];

endmodule



/*module datamemory(d_out, d_in, q, clk, DM_we);
input[7:0] d_in;
input[7:0] q;
input clk;
input DM_we;

output reg[7:0] d_out;

wire [6:0] addr;
assign addr = q[7:1];
reg[7:0] memoryvals[127:0]; //Make 128 bits by 8 bits (128 bytes) to hold all the memory

always @(posedge clk) begin
	//addr = q[7:1]; //set address equal to first 7 bits of out of address latch. LSB isn't accounted for
	if (DM_we == 1) begin //if our FSM says that we're writing, assigns bits at address equal to d_in
		memoryvals[addr] = d_in; 
		//d_out <= z;
	end 
	else if (DM_we == 0) begin //if our FSM says we're reading, assigns d_out equal to bits at address
		d_out = memoryvals[addr];
	end
	end

wire[7:0] tempreg1, tempreg2;
assign tempreg1 = memoryvals[0];
assign tempreg2 = memoryvals[1];
endmodule */


