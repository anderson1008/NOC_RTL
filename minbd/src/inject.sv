// Injector

`ifndef _INJECT_SV
`define _INJECT_SV
`timescale 1ns/1ps
`include "global.svh"
`include "flit.svh"

module inject (
inject_req,
din_inject,
din_0,
din_1,
din_2,
din_3,
dout_0,
dout_1,
dout_2,
dout_3,
inject_gnt
);
input flit_int_t din_0, din_1, din_2, din_3, din_inject;
input inject_req;
output flit_int_t dout_0, dout_1, dout_2, dout_3;
output inject_gnt;

logic [3:0] first_idle_chnl;

first_one #(4) search_first_idle_chnl ({~din_3.vld, ~din_2.vld, ~din_1.vld, ~din_0.vld}, first_idle_chnl);

assign dout_0 = (first_idle_chnl[0] && inject_req) ? din_inject : din_0;
assign dout_1 = (first_idle_chnl[1] && inject_req) ? din_inject : din_1;
assign dout_2 = (first_idle_chnl[2] && inject_req) ? din_inject : din_2;
assign dout_3 = (first_idle_chnl[3] && inject_req) ? din_inject : din_3;

assign inject_gnt = |first_idle_chnl && inject_req;

endmodule

`endif