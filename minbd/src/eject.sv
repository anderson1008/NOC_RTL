// Ejector

`ifndef _EJECT_SV
`define _EJECT_SV
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module eject (
rand_num,
din_0,
din_1,
din_2,
din_3,
dout_0,
dout_1,
dout_2,
dout_3,
dout_local
);


input flit_int_t din_0, din_1, din_2, din_3;
input [1:0] rand_num;
output flit_int_t dout_0, dout_1, dout_2, dout_3, dout_local;


// Mark the local destined flit
// Extract golden bit, silver bit, flitID

logic [3:0] local_vec;
logic [3:0] gold_vec;
logic [3:0] silver_vec;
logic [`WIDTH_PKTSZ-1:0] flit_id_vec [0:3];
logic [3:0] win_vec;

assign local_vec[0] = din_0.ppv[4] && din_0.vld;
assign local_vec[1] = din_1.ppv[4] && din_1.vld;
assign local_vec[2] = din_2.ppv[4] && din_2.vld;
assign local_vec[3] = din_3.ppv[4] && din_3.vld;

assign gold_vec[0] = din_0.golden;
assign gold_vec[1] = din_1.golden;
assign gold_vec[2] = din_2.golden;
assign gold_vec[3] = din_3.golden;

assign silver_vec [0] = din_0.silver;
assign silver_vec [1] = din_1.silver;
assign silver_vec [2] = din_2.silver;
assign silver_vec [3] = din_3.silver;

assign flit_id_vec[0] = din_0.flit_id;
assign flit_id_vec[1] = din_0.flit_id;
assign flit_id_vec[2] = din_0.flit_id;
assign flit_id_vec[3] = din_0.flit_id;

// Arbitrate among all local destined flit; Generate a one-hot encoded vector showing the winner 
//   If destined to local port and win the arbitration, flit is directly to local output. The original flit is zero out.
//   Other flits will be retained on the original channel
arbiter_4to1 arbiter_4to1_inst (
.rand_num           (rand_num),
.vld_vec            (local_vec),
.gold_vec           (gold_vec),
.silver_vec         (silver_vec),
.flit_id_vec        ({flit_id_vec[3], flit_id_vec[2], flit_id_vec[1], flit_id_vec[0]}),
.win_vec            (win_vec)
);

remove_one_flit  remove_one_flit_inst(
.din_0           (din_0),
.din_1           (din_1),
.din_2           (din_2),
.din_3           (din_3),
.chnl_vec        (win_vec),
.dout_0          (dout_0),
.dout_1          (dout_1),
.dout_2          (dout_2),
.dout_3          (dout_3),
.removed_flit    (dout_local)
);

endmodule

`endif