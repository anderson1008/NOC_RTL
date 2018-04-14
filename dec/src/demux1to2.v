`timescale 1ns / 1ps

// demux 1 to 2
module demux1to2 #(parameter WIDTH = 1) (dataIn, sel, aOut, bOut);

input 	[WIDTH-1:0] dataIn;
input               sel;
output	[WIDTH-1:0] aOut, bOut;

assign aOut = sel ? 0 : dataIn;
assign bOut = sel ? dataIn : 0;

endmodule