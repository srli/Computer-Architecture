module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
input clk;
input sclk_pin;
input cs_pin;
output miso_pin;
input mosi_pin;
output [7:0] leds;
input faultinjector_pin;
//output wire miso_buffout;

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
wire[7:0] dm_dout;

wire dff_out;
wire tri_output;

inputconditioner mosi_cond (clk, mosi_pin, mosi_conditioned, mosi_positiveedge, mosi_negativeedge);
inputconditioner sclk_cond (clk, sclk_pin, sclk_conditioned, sclk_positiveedge, sclk_negativeedge);
inputconditioner cs_cond (clk, cs_pin, cs_conditioned, cs_positiveedge, cs_negativeedge);
inputconditioner fault_cond (clk, fault_pin, fault_conditioned, fault_positiveedge, fault_negativeedge);

//AddressLatch(address, parallel_in, clk, wrenable);
AddressLatch addr_latch (address, parallelDataOut, clk, ADDR_we);

//datamemory(d_out, d_in, q, clk, DM_we);
datamemory data_mem (dm_dout, parallelDataOut, address, clk, DM_we);

//shiftregister(clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut, faultinjector);
shiftregister spi_shiftreg (clk, sclk_positiveedge, SR_we, dm_dout, mosi_conditioned, parallelDataOut, serialDataOut);

//dff(q, d, ce, clk);
dff dff_thing (dff_out, serialDataOut, sclk_negativeedge, clk);


//tristatebuffer(tri_output, tri_enable, tri_input);
tristatebuffer tsb (miso_pin, miso_buff, dff_out, clk);


//finitestatemachine(miso_buff, DM_we, ADDR_we, SR_we, cs_conditioned, shiftregp, sclk_positiveedge);
finitestatemachine fsm (clk, cs_conditioned, sclk_positiveedge, parallelDataOut[0], SR_we, DM_we, ADDR_we, miso_buff);




//assign miso_pin = dff_out;

endmodule

module testSPIMemory;
reg clk;
reg sclk;
reg cs = 1;
wire miso;
reg mosi;
reg fault = 1;
wire[7:0] leds;

spiMemory spimem (clk, sclk, cs, miso, mosi, leds, fault);
//module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
initial clk=0;
always #10 clk = !clk;

initial sclk=0;
always #1000 sclk = !sclk;

initial begin
    cs = 1;
    #2000

// WRITE 0x55 to address 1
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;

    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;

    #2000
    cs = 1;
    mosi = 0;

// WRITE 0x0 to address 1
    #2000
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;

    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
   #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 1;
    #2000
    mosi = 1;
    #2000
    mosi = 1;

    #2000
    cs = 1;
    mosi = 0;

// READ from address 1
    #8000
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 1;
    #18000
    cs = 1;
end

endmodule
