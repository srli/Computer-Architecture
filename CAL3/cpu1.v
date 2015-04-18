module data_memory(clk, regWE, Addr, DataIn, DataOut); //this is the data memory, we have to set up like mips
 input clk, regWE;
 input[9:0] Addr;
 input[31:0] DataIn;
 output[31:0] DataOut;

reg [31:0] mem[1023:0];
always @(posedge clk)
 if (regWE) mem[Addr] <= DataIn;

assign DataOut = mem[Addr];
endmodule

module instruction_memory(clk, Addr, DataOut); //reads our assembly code from "file.dat", puts this all into instruction_memory
 input clk;
 input[9:0] Addr;
 output[31:0] DataOut;

reg [31:0] mem[1023:0];
initial $readmemh(?file.dat?, mem);

assign DataOut = mem[Addr];
endmodule

module cpu;
//initialize
reg [31:0] pc = 0;
reg [31:0] npc = 0;
wire [31:0] instruction;
wire regWE, addr, dataout; //TO DO: MAKE SIZES GOOD
wire [31:0] datain;


data_memory d_m1 (clk, regWE, addr, datain, dataout);
instruction_memory i_m1 (clk, pc, instruction);
fsm fsm1 (encoding, clk, reset); //TO DO: SET THESE WIRES

begin
	
case (encoding): 
	6'b000001: begin
		 operation = instruction[31:26]; //INstruction fetch 
		pc = pc + 4; 
	end 
	6'b000010:  
	case(operation)
		000011: begin //jump and link
			datain <= pc + 8; 
			addr <= 31;
			i_m1 <= instruction[25:0];
			pc <= pc[31:28], i_m1[25:0], 2'b00;
			reset = 1;
			end
		000000: begin //jump register
			s = instruction[25:21];
			pc = s;
			end
	endcase

endcase

//input1 = instruction[25:21];
//input2 = instruction[20:16];


endmodule

module fsm(encoding, clk, reset);
input reset;
input clk;
output reg[5:0]encoding;

//wire encodin = 6'b000000;

always @(posedge clk) begin
if (reset) begin
	encoding = 6'b000000;
end
else if (!reset) begin
	if (encoding == 6'b100000) begin
		encoding = 6'b000001
	end
	else if begin	
	encoding = encoding << 1;
	end
end
endmodule 