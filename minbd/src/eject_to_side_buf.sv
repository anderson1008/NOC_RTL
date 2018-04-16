`ifndef _EJECT_TO_SIDE_BUF
`define _EJECT_TO_SIDE_BUF
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module eject_to_side_buf (
rand_num,
full,
redirect_gnt,
din_0,
din_1,
din_2,
din_3,
dout_0,
dout_1,
dout_2,
dout_3,
dout_side_buf,
deflect_to_side_buf_vld
);

input [1:0] rand_num;
input       full;
input       redirect_gnt;
input   flit_int_t din_0, din_1, din_2, din_3;
output  flit_int_t dout_0, dout_1, dout_2, dout_3, dout_side_buf;
output  deflect_to_side_buf_vld;

logic [3:0] deflect_vec, side_buf_eject_gnt;
flit_int_t removed_flit;

assign deflect_vec = {din_3.deflect, din_2.deflect, din_1.deflect, din_0.deflect};

pick_1out4_rand find_side_buf_eject (
.data_in  (deflect_vec),
.rand_num (rand_num),
.data_out (side_buf_eject_gnt)
);

assign deflect_to_side_buf_vld = (~redirect_gnt && ~full && |deflect_vec);

remove_one_flit  remove_one_flit_inst(
.din_0           (din_0),
.din_1           (din_1),
.din_2           (din_2),
.din_3           (din_3),
.chnl_vec        (side_buf_eject_gnt),
.dout_0          (dout_0),
.dout_1          (dout_1),
.dout_2          (dout_2),
.dout_3          (dout_3),
.removed_flit    (removed_flit)
);

assign dout_side_buf = deflect_to_side_buf_vld ? removed_flit : '0;

endmodule
`endif