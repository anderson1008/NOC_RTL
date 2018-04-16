// arbiter 

`ifndef _ARBITER_SV
`define _ARBITER_SV
`timescale 1ns / 1ps

`include "global.svh"

// Priority:
//     + Has flit
//     + gold
//     + silver
//     + flit_id
//     + random
//  Output: the label of winning flit


module arbiter # (parameter WIDTH_LABEL = 1) (
rand_num,
label_0,
label_1,
vld_0,
vld_1,
gold_0,
gold_1,
silver_0,
silver_1,
flit_id_0,
flit_id_1,
label_win
);

input vld_0, vld_1, gold_0, gold_1, silver_0, silver_1;
input [WIDTH_LABEL-1:0] label_0, label_1;
input [`WIDTH_PKTSZ-1:0] flit_id_0, flit_id_1;
input rand_num;
output [WIDTH_LABEL-1:0] label_win;

logic win_0, win_1;

assign win_0 = (vld_0 && ~vld_1) || 
               (vld_0 && vld_1 && gold_0 && ~gold_1) ||
							 (vld_0 && vld_1 && ~gold_0 && ~gold_1 && silver_0 && ~silver_1) ||
							 (vld_0 && vld_1 && ~gold_0 && ~gold_1 && ~silver_0 && ~silver_1 && (flit_id_0 < flit_id_1)) ||
							 (vld_0 && vld_1 && ~gold_0 && ~gold_1 && ~silver_0 && ~silver_1 && (flit_id_0 == flit_id_1) && (rand_num == 1));
assign win_1 = ~win_0 && vld_1;

assign label_win = win_0 ? label_0 : win_1 ? label_1 : 'h0;



endmodule

`endif