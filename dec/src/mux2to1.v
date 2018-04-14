`timescale 1ns / 1ps

// 2 to 1 mux

module mux2to1 #(parameter WIDTH = 1) (aIn, bIn, sel, dataOut);

input 	[WIDTH-1:0] aIn, bIn;
input               sel;
output 	[WIDTH-1:0] dataOut;

// sel =	1: dataOut = bIn; 
// sel =	0: dataOut = aIn;
assign dataOut = sel ? bIn : aIn; 

endmodule