// 4 to 1 arbiter

`ifndef _ARBITER_4TO1_SV
`define _ARBITER_4TO1_SV
`timescale 1ns / 1ps

`include "global.svh"

module arbiter_4to1 (
rand_num,
vld_vec,
gold_vec,
silver_vec,
flit_id_vec,
win_vec
);

input [1:0] rand_num;
input [3:0] vld_vec;
input [3:0] gold_vec;
input [3:0] silver_vec;
input [4*`WIDTH_PKTSZ-1:0] flit_id_vec;
output [3:0] win_vec;


logic vld_win_st1_0, vld_win_st1_1;
logic gold_win_st1_0, gold_win_st1_1;
logic silver_win_st1_0, silver_win_st1_1;
logic [`WIDTH_PKTSZ-1:0] flit_id_win_st1_0, flit_id_win_st1_1;
logic [1:0] winner_st1_0, winner_st1_1, winner;

arbiter # (
.WIDTH_LABEL (2)
) arb_st_1_0 (
.rand_num   (rand_num[0]),
.label_0    (2'd0),
.label_1    (2'd1),
.vld_0      (vld_vec[0]),
.vld_1      (vld_vec[1]),
.gold_0     (gold_vec[0]),
.gold_1     (gold_vec[1]),
.silver_0   (silver_vec[0]),
.silver_1   (silver_vec[1]),
.flit_id_0  (flit_id_vec[0 +: `WIDTH_PKTSZ]),
.flit_id_1  (flit_id_vec[`WIDTH_PKTSZ+:`WIDTH_PKTSZ]),
.label_win  (winner_st1_0)
);

assign vld_win_st1_0 = (~vld_vec[0] && ~vld_vec[1]) ? 'h0 : winner_st1_0 ? vld_vec[1] : vld_vec[0];
assign gold_win_st1_0 = (~vld_vec[0] && ~vld_vec[1]) ? 'h0 : winner_st1_0 ? gold_vec[1] : gold_vec[0];
assign silver_win_st1_0 = (~vld_vec[0] && ~vld_vec[1]) ? 'h0 : winner_st1_0 ? silver_vec[1] : silver_vec[0];
assign flit_id_win_st1_0 = (~vld_vec[0] && ~vld_vec[1]) ? 'h0 : winner_st1_0 ? flit_id_vec[`WIDTH_PKTSZ+:`WIDTH_PKTSZ] : flit_id_vec[0 +: `WIDTH_PKTSZ];

arbiter # (
.WIDTH_LABEL (2)
) arb_st_1_1 (
.rand_num   (rand_num[1]),
.label_0    (2'd2),
.label_1    (2'd3),
.vld_0      (vld_vec[2]),
.vld_1      (vld_vec[3]),
.gold_0     (gold_vec[2]),
.gold_1     (gold_vec[3]),
.silver_0   (silver_vec[2]),
.silver_1   (silver_vec[3]),
.flit_id_0  (flit_id_vec[2*`WIDTH_PKTSZ +: `WIDTH_PKTSZ]),
.flit_id_1  (flit_id_vec[3*`WIDTH_PKTSZ +: `WIDTH_PKTSZ]),
.label_win  (winner_st1_1)
);

assign vld_win_st1_1 = (~vld_vec[2] && ~vld_vec[3]) ? 'h0 : winner_st1_1 ? vld_vec[3] : vld_vec[2];
assign gold_win_st1_1 = (~vld_vec[2] && ~vld_vec[3]) ? 'h0 : winner_st1_1 ? gold_vec[3] : gold_vec[2];
assign silver_win_st1_1 = (~vld_vec[2] && ~vld_vec[3]) ? 'h0 : winner_st1_1 ? silver_vec[3] : silver_vec[2];
assign flit_id_win_st1_1 = (~vld_vec[2] && ~vld_vec[3]) ? 'h0 : winner_st1_1 ? flit_id_vec[3*`WIDTH_PKTSZ+:`WIDTH_PKTSZ] : flit_id_vec[2*`WIDTH_PKTSZ +: `WIDTH_PKTSZ];

arbiter # (
.WIDTH_LABEL (2)
) arb_st_2_0 (
.rand_num   (rand_num[1]),
.label_0    (winner_st1_0),
.label_1    (winner_st1_1),
.vld_0      (vld_win_st1_0),
.vld_1      (vld_win_st1_1),
.gold_0     (gold_win_st1_0),
.gold_1     (gold_win_st1_1),
.silver_0   (silver_win_st1_0),
.silver_1   (silver_win_st1_1),
.flit_id_0  (flit_id_win_st1_0),
.flit_id_1  (flit_id_win_st1_1),
.label_win  (winner)
);

assign win_vec = 1'b1 << winner;

endmodule
`endif