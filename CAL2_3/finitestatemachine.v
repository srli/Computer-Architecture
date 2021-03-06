module finitestatemachine(clk, cs_conditioned,  sclk_positiveedge, shiftregp, SR_we, DM_we, ADDR_we, miso_buff);
output reg miso_buff, DM_we, ADDR_we, SR_we;
input cs_conditioned, shiftregp, sclk_positiveedge, clk;

reg[3:0] state = 0; //this will be out state for our 7 states 
reg[3:0] count = 0; 

parameter GET = 0;
parameter GOT = 1;
parameter READ = 2;
parameter READ2 = 3;
parameter READ3 = 4;
parameter WRITE = 5;
parameter WRITE2 = 6;
parameter DONE = 7;

always @(posedge clk) begin
if (!cs_conditioned) begin
count = count + sclk_positiveedge;
end

else if (cs_conditioned) begin
count = 0;
end
	miso_buff = 0;
	DM_we = 0;
	ADDR_we = 0;
	SR_we = 0; 

if (state == GET) begin
		if (count < 8) begin	
			//count = count + 1; 
		end 
		else if (count  == 8) begin	
			state = GOT; 
		end 
end 

else if (state == GOT) begin 
	//`GOT: begin  //GOT, no counter
	//tempcounter = 0; 
		ADDR_we = 1;
		count = 0;

		if (shiftregp == 1) begin //wrenable 1, reading, state 3
			state = READ; 
		end 
		else if (shiftregp == 0) begin //wrenable 0, writing, state 
			//state <= 5;
				state = WRITE; 		
		end 

end 

else if (state == READ) begin 
//`READ: begin
//tempcounter = tempcounter + 1;
	state = READ2; 
end 

else if (state == READ2) begin 
//`READ2: begin
//tempcounter = tempcounter + 1;
	SR_we = 1; 
	state = READ3;  
end 

else if (state == READ3) begin 
//`READ3: begin
//tempcounter = tempcounter + 1;
	miso_buff = 1; 
	if (count <8) begin  
		//count = count + 1;			
	end 
	else if (count == 8) begin  
		state = DONE; 
	end 
end 

else if (state == WRITE) begin 
//`WRITE: begin
//tempcounter = tempcounter + 1;
	if (count < 8) begin
		//count = count + 1;
	end
	else if (count == 8) begin
		count = 0;
		state = WRITE2;
	end
end 

else if (state == WRITE2) begin
//`WRITE2: begin
//tempcounter = tempcounter + 1;
		DM_we = 1;
		state = DONE;
end

	//`DONE: begin
	//tempcounter = tempcounter + 1;
else if (state == DONE) begin
	count = 0;
	state = GET;
end
end
endmodule