// Redirection

`ifndef _REDIRECT_SV
`define _REDIRECT_SV
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module redirect (
rand_num,
starve,
full,
din_0,
din_1,
din_2,
din_3,
dout_0,
dout_1,
dout_2,
dout_3,
dout_redirected,
redirect_gnt
);

input flit_int_t  din_0, din_1, din_2, din_3;
input             starve, full;
input [1:0]       rand_num;
output flit_int_t dout_0, dout_1, dout_2, dout_3, dout_redirected;
output            redirect_gnt;

logic [3:0] redirect_sel;

assign redirect_sel = (starve && ~full && din_0.vld && din_1.vld && din_2.vld && din_3.vld) ? ( 1'b1 << rand_num ) : 'h0;

remove_one_flit  remove_one_flit_inst(
.din_0           (din_0),
.din_1           (din_1),
.din_2           (din_2),
.din_3           (din_3),
.chnl_vec        (redirect_sel),
.dout_0          (dout_0),
.dout_1          (dout_1),
.dout_2          (dout_2),
.dout_3          (dout_3),
.removed_flit    (dout_redirected)
);

assign redirect_gnt = |redirect_sel;

endmodule

`endif