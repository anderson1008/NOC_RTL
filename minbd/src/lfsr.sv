// 4-bit Fibonacci LFSR

`ifndef _LFSR_SV
`define _LFSR_SV
`timescale 1ns/1ps

module lfsr (
clk,
n_rst,
data
);

input            clk, n_rst;
output reg [2:0] data;

logic feedback;

assign feedback = data[1] ^ data[2];

always @ (posedge clk or negedge n_rst) 
  if (~n_rst) data <= 3'hF;
	else data <= {data[2:0], feedback};

endmodule


`endif