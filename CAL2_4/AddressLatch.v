module AddressLatch(address, parallel_in, clk, wrenable); 
//outputs 
output reg[7:0] address;

//inputs 
input clk; 
input wrenable; 
input [7:0] parallel_in; //either address or data

//Makes sure that we alternate between storing the data address and inputting the data
always @(posedge clk)begin
	if (wrenable)begin
		address <= parallel_in;
	end
end
endmodule 