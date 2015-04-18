module shiftregister(clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut);
parameter width = 8;
input               clk;
input               peripheralClkEdge; //Edge indicator
input               parallelLoad;
output wire [width-1:0]   parallelDataOut;
output              serialDataOut;
input[width-1:0]    parallelDataIn;
input               serialDataIn;
//input					  faultinjector;

reg[width-1:0]      shiftregistermem;

always @(posedge clk) begin
	if (parallelLoad == 1) begin
		shiftregistermem = parallelDataIn;
	end
	else if (parallelLoad == 0 && peripheralClkEdge == 1) begin// && faultinjector == 0) begin
		shiftregistermem = shiftregistermem << 1;
		shiftregistermem[0] = serialDataIn;
	end
end

assign parallelDataOut = shiftregistermem;
assign serialDataOut = parallelDataOut[7];

endmodule
