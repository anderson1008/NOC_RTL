`timescale 1ns / 1ps

`include "global.vh"

// last bit
module lastBit (dataIn, dataOut);

input    [3:0]      dataIn;
output   [3:0]      dataOut;

assign dataOut [0] = dataIn[0];
assign dataOut [1] = ~dataIn[0] && dataIn[1];
assign dataOut [2] = ~dataIn[0] && ~dataIn[1] && dataIn[2]; 
assign dataOut [3] = ~dataIn[0] && ~dataIn[1] && ~dataIn[2] && dataIn[3];

endmodule
