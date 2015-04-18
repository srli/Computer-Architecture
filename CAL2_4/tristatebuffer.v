module tristatebuffer(tri_output, tri_enable, tri_input, clk);

input tri_enable, tri_input, clk; //MISO_buff = tri_enable, Q from DFF = tri_input
output reg tri_output; //final output of spimem

always @(posedge clk) begin
	if (tri_enable == 0) begin
		tri_output = 1'b z;
	end
	else if (tri_enable == 1) begin
		tri_output = tri_input;
	end
end

endmodule 