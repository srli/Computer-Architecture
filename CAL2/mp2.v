`timescale 1ns / 1ps

// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module mp2(led, gpioBank1, gpioBank2, clk, sw, btn);
//module mp2(led, gpioBank1, gpioBank2, clk);
//module mp2(led, clk, sw, btn);
output[7:0] led;
output[3:0] gpioBank1;
input[3:0] gpioBank2;
input clk;
input[7:0] sw;
input[3:0] btn;

wire parallel_in;
assign parallel_in = 8'b10100101;

wire serial_out;
wire[7:0] testled;
//wire[2:0] gpioBank1_emptyvals = 0;

//TopLevelShiftRegisterBringup shift_reg_bringup (led, serial_out, btn[0], sw[0], sw[1], clk, parallel_in);
//TopLevelSPIMemory spi_mem_bringup (clk, sclk_sw, cs_btn, mosi_sw, faultinjector_sw, miso_pin, leds);
//TopLevelSPIMemory spi_mem_bringup (clk, sw[0], btn[0], sw[1], sw[2], thing, led);

//TopLevelSPIMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
TopLevelSPIMemory spi_mem_bringup (clk, gpioBank2[0], gpioBank2[1], gpioBank1[0], gpioBank2[2], led, sw[0]);
assign gpioBank1[3:1] = gpioBank2[3];

endmodule