`timescale 1ns / 1ps

`include "global.vh"

// Permuter Block
module permuterBlock (inFlit0, inFlit1, swap, outFlit0, outFlit1);

input                             swap;
input   [`WIDTH_INTERNAL_PV-1:0] 	inFlit0,inFlit1;
output 	[`WIDTH_INTERNAL_PV-1:0]	outFlit0, outFlit1;

wire	[`WIDTH_INTERNAL_PV-1:0] swapFlit [1:0];
wire	[`WIDTH_INTERNAL_PV-1:0] straightFlit [1:0];


demux1to2 #(`WIDTH_INTERNAL_PV) permuterblock_demux0 (inFlit0, swap, straightFlit[0], swapFlit[0]);

demux1to2 #(`WIDTH_INTERNAL_PV) permuterblock_demux1 (inFlit1, swap, straightFlit[1], swapFlit[1]);

mux2to1 #(`WIDTH_INTERNAL_PV) permuterblock_mux0 (straightFlit[0], swapFlit[1], swap, outFlit0);

mux2to1 #(`WIDTH_INTERNAL_PV) permuterblock_mux1 (straightFlit[1], swapFlit[0], swap, outFlit1);

endmodule
