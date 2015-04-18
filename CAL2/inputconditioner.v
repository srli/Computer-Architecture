module inputconditioner(clk, noisysignal, conditioned, positiveedge, negativeedge);
output reg conditioned = 0;
output reg positiveedge = 0;	// output wire positiveedge
output reg negativeedge = 0;	// output wire negativeedge
input clk, noisysignal;

parameter counterwidth = 3;
parameter waittime = 3;

reg[counterwidth-1:0] counter =0;
reg synchronizer0 = 0;
reg synchronizer1 = 0;

always @(posedge clk ) begin
	if(conditioned == synchronizer1) begin
		counter = 0;
		positiveedge = 0;
		negativeedge = 0;
	end
	else begin
		if( counter == waittime) begin
			counter = 0;
			if(synchronizer1 > conditioned) begin
				positiveedge = 1;
			end
			else begin
				negativeedge = 1;
			end

			conditioned = synchronizer1;
		end
		else
			counter = counter+1;
	end
	synchronizer1 = synchronizer0;
	synchronizer0 = noisysignal;
end
endmodule
/*
module testconditioner;
wire conditioned;
wire rising;
wire falling;
reg pin, clk;
reg ri;
always @(posedge clk) ri=rising;
inputconditioner dut(clk, pin, conditioned, rising, falling);

initial clk=0;
always #10 clk=!clk;    // 50MHz Clock

initial begin
// Your Test Code
// Be sure to test each of the three things the conditioner does:
// Synchronize, Clean, Preprocess (edge finding)
$display("Conditioned, Rising, Falling, Pin, Clk, rising");
pin = 0;  #100; pin = 1; #100;  
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling);
pin = 1;  #100; pin = 0; #250;  
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling); 
pin = 1;  #10; pin = 0; #100;  
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling);
pin = 0;  #100; pin = 1; #100;  
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling);
pin = 0;  #10; pin = 1; #10;
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling);
pin = 1;  #100; pin = 0; #100;
$display("%b   %b | %b   %b   %b", clk, pin, conditioned, rising, falling);
end

endmodule*/