module dff(q, d, ce, clk);		// dff means d-flip-flop
input d, ce, clk;
output reg q;

always @(posedge clk) begin
	if (ce == 1) begin	// if the clock edge is 1 (of a different clock)
		q <= d;		// d-flip flop output is the input data
	end
	// otherwise the D flip flop outputs the previous value that it was outputting
end

endmodule
