

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
wire fault_conditioned, fault_positiveedge, fault_negativeedge;

wire SR_we;
wire ADDR_we;
wire DM_we;

wire[7:0] d_outshiftreg;
wire serialDataOut;
wire[7:0] parallelDataOut;

wire[7:0] address;
wire[7:0] d_in, q;
wire[7:0] d_outdatamem;

wire dff_out;
wire tri_output;

inputconditioner mosi_cond (clk, mosi_pin, mosi_conditioned, mosi_positiveedge, mosi_negativeedge);
inputconditioner sclk_cond (clk, sclk_pin, sclk_conditioned, sclk_positiveedge, sclk_negativeedge);
inputconditioner cs_cond (clk, cs_pin, cs_conditioned, cs_positiveedge, cs_negativeedge);
inputconditioner fault_cond (clk, fault_pin, fault_conditioned, fault_positiveedge, fault_negativeedge);

//finitestatemachine(miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, shiftregp, sclk_positiveedge);
//finitestatemachine fsm (miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, leds[0], sclk_positiveedge);
finitestatemachine fsm (miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, parallelDataOut[0], sclk_positiveedge, leds, clk);


//shiftregister(clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut, faultinjector);
//shiftregister spi_shiftreg (clk, sclk_positiveedge, SR_we, d_outdatamem, mosi_conditioned, leds, serialDataOut, fault_positiveedge);
shiftregister spi_shiftreg (clk, sclk_positiveedge, SR_we, d_outdatamem, mosi_conditioned, parallelDataOut, serialDataOut, fault_positiveedge);

//AddressLatch(address, parallel_in, clk, wrenable);
//AddressLatch addr_latch (address, leds, clk, ADDR_we);
AddressLatch addr_latch (address, parallelDataOut, clk, ADDR_we);

//datamemory(d_out, d_in, q, clk, DM_we);
//datamemory data_mem (d_outdatamem, leds, address, clk, DM_we); // TO DO change leds to parallel out aop
datamemory data_mem (d_outdatamem, parallelDataOut, address, clk, DM_we); // TO DO change leds to parallel out aop

//dff(q, d, ce, clk);
dff dff_thing (dff_out, serialDataOut, sclk_negativeedge, clk);

//tristatebuffer(tri_output, tri_enable, tri_input);
//assign miso_pin = 1; 
tristatebuffer tsb (miso_pin, miso_buff, dff_out);
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
	addr <= q[7:1]; //set address equal to first 7 bits of out of address latch. LSB isn't accounted for
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
		q <= d;		// d-flip flop output is the input data
	end
	// otherwise the D flip flop outputs the previous value that it was outputting
end

endmodule

module finitestatemachine(miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, shiftregp, sclk_positiveedge, stateout, clk);
output reg miso_buff, DM_we, ADDR_we, SR_we;
input cs_conditioned, shiftregp, sclk_positiveedge;
input clk;
output reg[7:0] stateout = 0;

reg[3:0] state = 0; //this will be out state for our 7 states 
reg[3:0] count = 0; 

reg[7:0] tempcounter = 0;

//wire cs_conditioned = 0;
parameter GET = 0;
parameter GOT = 1;
parameter READ = 2;
parameter READ2 = 3;
parameter READ3 = 4;
parameter WRITE = 5;
parameter WRITE2 = 6;
parameter DONE = 7;

//assign cs_conditioned = 0;

always @(posedge clk) begin
if (sclk_positiveedge == 1) begin
//stateout = state + 1; 
//tempcounter = tempcounter + 1;
//stateout = tempcounter;
	miso_buff = 0;
	DM_we = 0;
	ADDR_we = 0;
	SR_we = 0; 

if (state == GET) begin
stateout[0] = 1;
	//tempcounter = tempcounter + 1;
	//count = 8;
//		if (count < 7) begin
		if ((count < 7) && (cs_conditioned == 0)) begin	
			count = count + 1; 
		end 
		//else	 if (count == 7) begin
		else if ((count  == 7) && (cs_conditioned == 0)) begin	
			state = GOT; 
			count = 0;
		end 
		else if (cs_conditioned == 1) begin
			count = 0;
		end
end 

else if (state == GOT) begin
stateout[1] = 1;
	//`GOT: begin  //GOT, no counter
	//tempcounter = 0; 
		ADDR_we = 1;
		count = 0; 
		if ((shiftregp == 1) && (cs_conditioned == 0)) begin //wrenable 1, reading, state 3
			state = READ; 
		end 
		else if ((shiftregp == 0) && (cs_conditioned == 0)) begin //wrenable 0, writing, state 
			//state <= 5;
				state = WRITE; 		
		end 
		else if (cs_conditioned ==1) begin 
			state = GET; 
		end
end 

else if (state == READ) begin
stateout[2] = 1;
//`READ: begin
//tempcounter = tempcounter + 1;
	if (cs_conditioned ==1) begin 
		state =GET;
	end 
	else if (cs_conditioned == 0) begin
		state = READ2; 
	end 
end 

else if (state == READ2) begin 
stateout[3] = 1;
//`READ2: begin
//tempcounter = tempcounter + 1;
	SR_we = 1; 
	if (cs_conditioned ==1) begin 
		state = GET; 
	end 
	else if (cs_conditioned == 0) begin  
		state = READ3; 
	end 
end 

else if (state == READ3) begin 
stateout[4] = 1;
//`READ3: begin
//tempcounter = tempcounter + 1;
	miso_buff = 1; 
	if ((count <7)  && (cs_conditioned ==0)) begin  
		count = count + 1;			
	end 
	else if ((count == 7)  && (cs_conditioned ==0)) begin  
		state = DONE; 
	end 
	else if (cs_conditioned ==1) begin 
		state = GET; 
	end 	
end 

else if (state == WRITE) begin 
stateout[5] = 1;
//`WRITE: begin
//tempcounter = tempcounter + 1;
	if ((count < 7) && (cs_conditioned == 0)) begin
		count = count + 1;
	end
	else if ((count == 7) && (cs_conditioned == 0)) begin
		count = 0;
		state = WRITE2;
	end
	else if (cs_conditioned == 1) begin
		state = GET;
	end
end 

else if (state == WRITE2) begin
stateout[6] = 1;
//`WRITE2: begin
//tempcounter = tempcounter + 1;
		DM_we = 1;
		if (cs_conditioned == 1) begin
			state = GET; 
		end
		else if (cs_conditioned == 0) begin
			state = DONE;
		end
end

	//`DONE: begin
	//tempcounter = tempcounter + 1;
else if (state == DONE) begin
stateout = 0;
	count = 0;
	state = GET;
end


end // end the if on positive edge
end //end always

endmodule


module tristatebuffer(tri_output, tri_enable, tri_input);

input tri_enable, tri_input; //MISO_buff = tri_enable, Q from DFF = tri_input
output reg tri_output; //final output of spimem

always @(tri_enable) begin
	if (tri_enable == 0) begin
		tri_output = 1'bz;
	end
	else if (tri_enable == 1) begin
		tri_output = tri_input;
	end
end

endmodule

//module testSPI;
//reg clk, sclk_pin, cs_pin, mosi_pin, faultinjector_pin; 
//wire miso_pin;
//wire[7:0] leds; 
//spiMemory testSPImem (clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
//
//
//always #5 clk = ~clk;
//always #500 sclk_pin = ~sclk_pin;
//initial begin
//clk = 0;
//sclk_pin = 0;
//mosi_pin = 1;
//cs_pin = 0;
//#100
//$display("MOSI %b, sclk %b, cs %b | MISO %b, leds %b", mosi_pin, sclk_pin, cs_pin, miso_pin, leds); 
//end
//
//
//
//endmodule