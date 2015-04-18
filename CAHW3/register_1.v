module register(q, d, wrenable, clk);
input	d;
input	wrenable;
input	clk;
output reg q;

always @(posedge clk) begin
    if(wrenable) begin
	q = d;
    end
end
endmodule