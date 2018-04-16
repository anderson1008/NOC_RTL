// 4 to 1 mux

`ifndef _MUX4TO1_SV
`define _MUX4TO1_SV
`timescale 1ns/1ps

`include "flit.svh"
`include "global.svh"

module mux4to1 (
din_0,
din_1,
din_2,
din_3,
sel,
dout
);

input  `MUX_DATA_T din_0, din_1, din_2, din_3;
input  [1:0]       sel;
output `MUX_DATA_T dout;

`MUX_DATA_T tmp_0, tmp_1;

`MUX2TO1(din_0, din_1, sel[0], tmp_0)
`MUX2TO1(din_2, din_3, sel[0], tmp_1)
`MUX2TO1(tmp_0, tmp_1, sel[1], dout)

endmodule
`endif