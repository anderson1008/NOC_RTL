`ifndef _RC_UC
`define _RC_UC
`timescale 1ns / 1ps

`include "global.svh"

module rcUC #(
  parameter CORD_X = 1,
	parameter CORD_Y = 1
	)(
  dst_x,
  dst_y,
  preferPortVector
);

input  [`WIDTH_COORD-1:0] dst_x, dst_y;
output [`NUM_DIR-1:0] preferPortVector;

assign preferPortVector [1] = dst_x > CORD_X;
assign preferPortVector [3] = dst_x < CORD_X;
assign preferPortVector [0] = (dst_y > CORD_Y) && ~preferPortVector [1] && ~preferPortVector [3];
assign preferPortVector [2] = (dst_y < CORD_Y) && ~preferPortVector [1] && ~preferPortVector [3];
assign preferPortVector [4] = (dst_x == CORD_X) && (dst_y == CORD_Y);    
    
endmodule
`endif