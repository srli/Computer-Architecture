// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module TopLevelSPIMemory(led, gpioBank1, gpioBank2, clk, sw, btn);
output[7:0] led;
output[3:0] gpioBank1;
input[3:0] gpioBank2;
input clk;
input[7:0] sw;
input[3:0] btn;

assign gpioBank1[3:1] = gpioBank2[3:1];

//spiMemory(clk, sclk_pin(13), cs_pin(10), miso_pin(12), mosi_pin(11), leds, faultinjector_pin);
spiMemory mem (clk, gpioBank2[2], gpioBank2[0], gpioBank1[0], gpioBank2[1], led, sw[0]);

endmodule
