// One hot to binary decoder

`ifndef _ONEHOT2BINARY_SV
`define _ONEHOT2BINARY_SV
`timescale 1ns/1ps

module onehot2binary #(parameter WIDTH=4) (
  one_hot,
	binary
);

localparam BIN_WIDTH = $clog2(WIDTH); 

input  [WIDTH-1:0]     one_hot;
output [BIN_WIDTH-1:0] binary;

integer i;
reg [BIN_WIDTH-1:0] pos_is_1;

always @ * begin
  pos_is_1 = '0;
  for (i=0; i<WIDTH; i++) begin
	  pos_is_1 = one_hot[i] ? (pos_is_1 | i[BIN_WIDTH-1:0]) : pos_is_1;
  end
end
assign binary = |one_hot ? pos_is_1: 'h0;

endmodule

`endif
