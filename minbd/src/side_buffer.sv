// Side buffer

`ifndef _SIDE_BUFFER_SV
`define _SIDE_BUFFER_SV
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module side_buffer (
clk,
n_rst,
din_redirect,
redirect_gnt,
deflect_to_side_buf_vld,
din_eject,
dout_inject,
inject_gnt,
starve,
full,
empty
);

input  clk, n_rst;
input  redirect_gnt, inject_gnt, deflect_to_side_buf_vld; 
input  flit_int_t din_redirect, din_eject;
output flit_int_t dout_inject;
output starve, full, empty;

logic [$clog2(`SIDE_BUF_CNT_TH)-1:0] counter;
flit_int_t                           sidebuf_dat_in;

// Determine starvation
assign starve = ~empty && (counter >= `SIDE_BUF_CNT_TH);

always @ (posedge clk or negedge n_rst) begin
  if (~n_rst) counter <= 'h0;
	else if (~empty && ~(redirect_gnt || deflect_to_side_buf_vld)) counter <= counter + 1'b1;
	else counter <= 'h0;
end

// Select a flit will be installed into FIFO
assign sidebuf_dat_in = redirect_gnt ? din_redirect : deflect_to_side_buf_vld ? din_eject : '0;

sync_fifo # (
.DATA_WIDTH (`WIDTH_FLIT_INT),
.ADDR_WIDTH (`DEPTH_SIDE_BUF)
)
side_buffer_inst
(
.clk      (clk),
.n_rst    (n_rst),
.din      (sidebuf_dat_in),
.wr_en    (redirect_gnt || deflect_to_side_buf_vld),
.dout     (dout_inject),
.rd_en    (inject_gnt),
.empty    (empty),
.full     (full)
);

endmodule

`endif