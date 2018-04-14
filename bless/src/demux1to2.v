`timescale 1ns / 1ps

// demux 1 to 2

module demux1to2 # (parameter PERM_WIDTH = 8) (dataIn, sel, aOut, bOut);

input 	[PERM_WIDTH-1:0] dataIn;
input                    sel;
output	[PERM_WIDTH-1:0] aOut, bOut;

assign aOut = sel ? 'h0 : dataIn;
assign bOut = sel ? dataIn : 'h0;

endmodule