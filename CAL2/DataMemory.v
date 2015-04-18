module DataMemory(clk, dataOut, address, writeEnable, dataIn);
parameter addresswidth = 7;
parameter depth = 2**addresswidth;
parameter width = 8;

output reg [width-1:0]  dataOut;

input clk;
input [addresswidth-1:0]    address;
input writeEnable;
input[width-1:0]    dataIn;

reg [width-1:0] memory [depth-1:0];

always @(posedge clk) begin
    if(writeEnable)
        memory[address] = dataIn;
     dataOut = memory[address];
     end

integer i;
initial begin
for(i=0;i<depth;i=i+1)
memory[i]=3*i;
end
endmodule
