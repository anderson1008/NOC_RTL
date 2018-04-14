`timescale 1ns / 1ps

`include "global.vh"

module rcUC #(
  parameter CORD_X = 1,
	parameter CORD_Y = 1
	)(
  dst,
  preferPortVector
);

input  [`DST_WIDTH-1:0] dst;
output [`NUM_PORT-1:0] preferPortVector;

wire [2:0] dst_x, dst_y;
	 
assign dst_x = dst[`X_COORD];
assign dst_y = dst[`Y_COORD];

assign preferPortVector [1] = dst_x > CORD_X;
assign preferPortVector [3] = dst_x < CORD_X;
assign preferPortVector [0] = (dst_y > CORD_Y) && ~preferPortVector [1] && ~preferPortVector [3];
assign preferPortVector [2] = (dst_y < CORD_Y) && ~preferPortVector [1] && ~preferPortVector [3];
assign preferPortVector [4] = (dst_x == CORD_X) && (dst_y == CORD_Y);    
    
endmodule
