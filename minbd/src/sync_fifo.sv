// Synchronous FIFO

`ifndef _SYNC_FIFO_SV
`define _SYNC_FIFO_SV
`timescale 1ns / 1ps

module sync_fifo (
clk,
n_rst,
din,
wr_en,
dout,
rd_en,
empty,
full
);

// FIFO Configuration
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 8;
localparam FIFO_DEPTH = 1 << ADDR_WIDTH;

// Port declaration
input                   clk, n_rst;
input                   wr_en, rd_en;
input  [DATA_WIDTH-1:0] din;
output [DATA_WIDTH-1:0] dout;
output                  empty, full;

// Internal variable 
reg [ADDR_WIDTH-1:0] rd_ptr, wr_ptr;
reg [ADDR_WIDTH:0]   status_cnt;
reg [DATA_WIDTH-1:0] buffer [0 : FIFO_DEPTH-1];

always @ (posedge clk or negedge n_rst)
  if (~n_rst) wr_ptr <= 'h0;
	else if (wr_en) wr_ptr <= wr_ptr + 1'b1;
	else wr_ptr <= wr_ptr;

always @ (posedge clk or negedge n_rst)
  if (~n_rst) rd_ptr <= 'h0;
  else if (rd_en) rd_ptr <= rd_ptr + 1'b1;
  else rd_ptr <= rd_ptr;	

always @ (posedge clk or negedge n_rst) begin
  if (~n_rst) status_cnt <= 'h0;
	else if (rd_en && ~wr_en && (status_cnt != 0)) status_cnt <= status_cnt - 1'b1;
	else if (~rd_en && wr_en && (status_cnt != FIFO_DEPTH)) status_cnt <= status_cnt + 1'b1;
	else status_cnt <= status_cnt;
end
	
	
assign dout = rd_en ? buffer[rd_ptr] : 'h0;

always @ (posedge clk)
  if (wr_en) buffer[wr_ptr] <= din;
	
assign empty = status_cnt == 0;
assign full  = status_cnt == FIFO_DEPTH;
	
endmodule

`endif