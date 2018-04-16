// remove one flit

`ifndef _REMOVE_ONE_FLIT_SV
`define _REMOVE_ONE_FLIT_SV
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module remove_one_flit(
din_0,
din_1,
din_2,
din_3,
chnl_vec,
dout_0,
dout_1,
dout_2,
dout_3,
removed_flit
);

input  flit_int_t din_0, din_1, din_2, din_3;
input  [3:0]      chnl_vec;
output flit_int_t dout_0, dout_1, dout_2, dout_3, removed_flit;

assign dout_0 = {`WIDTH_FLIT_INT{~chnl_vec[0]}} & din_0; 
assign dout_1 = {`WIDTH_FLIT_INT{~chnl_vec[1]}} & din_1; 
assign dout_2 = {`WIDTH_FLIT_INT{~chnl_vec[2]}} & din_2; 
assign dout_3 = {`WIDTH_FLIT_INT{~chnl_vec[3]}} & din_3; 

wire [1:0] chnl_dec;
onehot2binary # (4) decoder_to_rm (chnl_vec, chnl_dec);
mux4to1 select_to_rm (din_0, din_1, din_2, din_3, chnl_dec, removed_flit);

endmodule
`endif