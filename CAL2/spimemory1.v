module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
input clk;
input sclk_pin;
input cs_pin;
output miso_pin;
input mosi_pin;
output [7:0] leds;
input faultinjector_pin;

wire mosi_conditioned, mosi_positiveedge, mosi_negativeedge;
wire sclk_conditioned, sclk_positiveedge, sclk_negativeedge;
wire cs_conditioned, cs_positiveedge, cs_negativeedge;

wire SR_we;
wire ADDR_we;
wire DM_we;

wire[7:0] d_outshiftreg;
wire serialDataOut;

wire[7:0] address;
wire[7:0] d_in, q;
wire[7:0] d_outdatamem;

wire dff_out;
wire tri_output;

inputconditioner mosi_cond (clk, mosi_pin, mosi_conditioned, mosi_positiveedge, mosi_negativeedge);
inputconditioner sclk_cond (clk, sclk_pin, sclk_conditioned, sclk_positiveedge, sclk_negativeedge);
inputconditioner cs_cond (clk, cs_pin, cs_conditioned, cs_positiveedge, cs_negativeedge);

finitestatemachine fsm (miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, leds[0], sclk_positiveedge);
shiftregister spi_shiftreg (clk, sclk_positiveedge, SR_we, d_outshiftreg, mosi_conditioned, leds, serialDataOut);
AddressLatch addr_latch (address, leds, clk, ADDR_we);
datamemory data_mem (d_outdatamem, d_in, q, clk, DM_we);
dff dff_thing (dff_out, serialDataOut, sclk_negativeedge, clk);
tristatebuffer tsb (tri_output, miso_buff, dff_out);

endmodule

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
		address = parallel_in;
	end
end
endmodule 


module datamemory(d_out, d_in, q, clk, DM_we);
input[7:0] d_in;
input[7:0] q;
input clk;
input DM_we;

output reg[7:0] d_out;

reg[6:0] addr;
reg[127:0] memoryvals[7:0]; //Make 128 bits by 8 bits (128 bytes) to hold all the memory

always @(posedge clk) begin
	assign addr = q[6:0]; //set address equal to first 7 bits of out of address latch. LSB isn't accounted for
	if (DM_we == 1) begin //if our FSM says that we're writing, assigns bits at address equal to d_in
		memoryvals[addr] <= d_in; 
		//d_out <= z;
	end 
	else if (DM_we == 0) begin //if our FSM says we're reading, assigns d_out equal to bits at address
		d_out <= memoryvals[addr];
	end
	end
endmodule

module dff(q, d, ce, clk);		// dff means d-flip-flop
input d, ce, clk;
output reg q;

always @(posedge clk) begin
	if (ce == 1) begin	// if the clock edge is 1 (of a different clock)
		assign q = d;		// d-flip flop output is the input data
	end
	// otherwise the D flip flop outputs the previous value that it was outputting
end

endmodule

module finitestatemachine(miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, shiftregp, sclk_positiveedge);
output reg miso_buff, DM_we, ADDR_we, SR_we;
input cs_conditioned, shiftregp, sclk_positiveedge;

reg[2:0] state = 0; //this will be out state for our 7 states 
reg[2:0] count = 0; 

reg[2:0] tempcounter = 0;

`define GET    0
`define GOT    1
`define READ   2
`define READ2  3
`define READ3  4
`define WRITE  5
`define WRITE2 6
`define DONE   7

always @(sclk_positiveedge) begin
//if (sclk_positiveedge == 1) begin 
tempcounter = tempcounter + 1;
	miso_buff = 0;
	DM_we = 0; 
	ADDR_we = 0; 
	SR_we = 0; 

case(state)
`GET: begin 
	tempcounter = tempcounter + 1;
	if ((count < 8) && (cs_conditioned == 0)) begin 
		count = count + 1; 
	end 
	else if ((count  == 8) && (cs_conditioned == 0)) begin  
		state = `GET; 
	end 
	else if (cs_conditioned ==1) begin
		count = 0; 
	end
end

`GOT: begin  //GOT, no counter 
	tempcounter = tempcounter + 1;
	ADDR_we = 1; 
	count = 0; 
	if ((shiftregp == 1) && (cs_conditioned ==0)) begin //wrenable 1, reading, state 3
		state = `READ; 
	end 
	else if ((shiftregp == 0) && (cs_conditioned == 0)) begin //wrenable 0, writing, state 
		//state <= 5;
			state = `WRITE; 		
	end 
	else if (cs_conditioned ==1) begin 
		state = `GET; 
	end
end

`READ: begin
tempcounter = tempcounter + 1;
	if (cs_conditioned ==1) begin 
		state = `GET; 
	end 
	else begin  
		state = `READ2; 
	end 
end

`READ2: begin
tempcounter = tempcounter + 1;
	SR_we = 1; 
	if (cs_conditioned ==1) begin 
		state = `GET; 
	end 
	else begin  
		state = `READ3; 
	end 
end

`READ3: begin
tempcounter = tempcounter + 1;
	miso_buff = 1; 
	if ((count <8)  && (cs_conditioned ==0)) begin  
		count = count + 1;			
	end 
	else if ((count ==8)  && (cs_conditioned ==0)) begin  
		state = `DONE; 
	end 
	else if (cs_conditioned ==1) begin 
		state = `GET; 
	end 	
end

`WRITE: begin
tempcounter = tempcounter + 1;
	if ((count < 8) && (cs_conditioned == 0)) begin
		count = count + 1;
	end
	else if ((count == 8) && (cs_conditioned == 0)) begin
		count = 0;
		state = `WRITE2;
	end
	else if (cs_conditioned == 1) begin
		state = `GET;
	end
end

`WRITE2: begin
tempcounter = tempcounter + 1;
	DM_we = 1;
	if (cs_conditioned ==1) begin
		state = `GET; 
	end 	
end

`DONE: begin
tempcounter = tempcounter + 1;
	count = 0;
	state = `GET;
end

endcase 
//end
end //end always
initial begin
#50
$display("counter %b", tempcounter);
end


endmodule


module tristatebuffer(tri_output, tri_enable, tri_input);

input tri_enable, tri_input; //MISO_buff = tri_enable, Q from DFF = tri_input
output reg tri_output; //final output of spimem

always @(tri_enable) begin
	if (tri_enable) begin
		//tri_output = z;
	end
	else if (tri_enable == 0) begin
		tri_output = tri_input;
	end
end

endmodule

/*module testSPI;
reg clk, sclk_pin, cs_pin, mosi_pin, faultinjector_pin; 
wire miso_pin;
wire[7:0] leds; 
spiMemory testSPImem (clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);

initial begin
mosi_pin = 1;
cs_pin = 0;
#5 sclk_pin = 0; #5 sclk_pin = 1;
#5 clk = 1; #5 clk = 0;
#5 clk = 1; #5 clk = 0;
#5 clk = 1; #5 clk = 0;
#5 sclk_pin = 0; #5 sclk_pin = 1;
#5 clk = 1; #5 clk = 0;
#5 clk = 1; #5 clk = 0;
#5 clk = 1; #5 clk = 0;

#100
$display("MOSI %b, sclk %b, cs %b | MISO %b, leds %b", mosi_pin, sclk_pin, cs_pin, miso_pin, leds); 
end



endmodule*/