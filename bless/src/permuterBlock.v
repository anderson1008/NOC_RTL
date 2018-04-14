// Permuter Block

`include "global.vh"

module permuterBlock # (parameter PERM_WIDTH = 8)(
  inFlit0,
  inFlit1, 
  swap, 
  outFlit0, 
  outFlit1
);

input                       swap;
input   [PERM_WIDTH-1:0] 	inFlit0,inFlit1;
output 	[PERM_WIDTH-1:0]	outFlit0, outFlit1;

wire	[PERM_WIDTH-1:0] swapFlit [1:0];
wire	[PERM_WIDTH-1:0] straightFlit [1:0];


demux1to2 # (PERM_WIDTH) demux0(inFlit0, swap, straightFlit[0], swapFlit[0]);
demux1to2 # (PERM_WIDTH) demux1(inFlit1, swap, straightFlit[1], swapFlit[1]);
mux2to1   # (PERM_WIDTH) mux0(straightFlit[0], swapFlit[1], swap, outFlit0);
mux2to1   # (PERM_WIDTH) mux1(straightFlit[1], swapFlit[0], swap, outFlit1);

endmodule
