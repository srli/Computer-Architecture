`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    13:47:18 10/29/2014 
// Design Name: 
// Module Name:    TopLevelSPIMemory 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
//module TopLevelSPIMemory(clk, gpioBank2, faultinjector_sw, gpioBank1, leds);
module TopLevelSPIMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
input clk, sclk_pin, cs_pin, mosi_pin, faultinjector_pin;
//input[3:0] gpioBank2;

//output[3:0] gpioBank1;
output[7:0] leds;
output miso_pin;


spiMemory spimemory (clk, sclk_pin, cs_pin, miso_pin, mosi_pin, leds, faultinjector_pin);
//spiMemory spimemory (clk, gpioBank2[0], gpioBank2[1], gpioBank1[0], gpioBank2[2], leds, faultinjector_sw);
//spiMemory spimemory (clk, gpioBank2[0], gpioBank2[1], gpioBank1[0], gpioBank2[2], leds, faultinjector_sw);

endmodule
