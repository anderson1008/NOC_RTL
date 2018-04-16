`ifndef _PERMUTER_BLOCK_SV
`define _PERMUTER_BLOCK_SV
`timescale 1ns / 1ps
`include "global.svh"
`include "flit.svh"

// Permuter Block
module permuter_block (din_0, din_1, swap, dout_0, dout_1);

input   swap;
input   flit_int_t 	din_0, din_1;
output 	flit_int_t	dout_0, dout_1;

flit_int_t swap_flit [0:1];
flit_int_t straight_flit [0:1];

`DEMUX1TO2(din_0, swap, straight_flit[0], swap_flit[0])
`DEMUX1TO2(din_1, swap, straight_flit[1], swap_flit[1])
`MUX2TO1(straight_flit[0], swap_flit[1], swap, dout_0)
`MUX2TO1(straight_flit[1], swap_flit[0], swap, dout_1)

endmodule

`endif