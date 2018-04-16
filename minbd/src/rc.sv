`ifndef _RC_SV
`define _RC_SV
`timescale 1ns / 1ps

`include "global.svh"

module rc # (
  parameter CORD_X = 1,
  parameter CORD_Y = 1
)
(
  dst_x,
  dst_y,
  preferPortVector
);

input  [`WIDTH_COORD-1:0] dst_x, dst_y;
output [`NUM_DIR-1:0]  preferPortVector;
 
rcUC # (CORD_X, CORD_Y) rcUC_inst(
.dst_x            (dst_x),
.dst_y            (dst_y),
.preferPortVector (preferPortVector)
);
    
endmodule    
`endif