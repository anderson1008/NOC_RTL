`timescale 1ns / 1ps

// 5 port xbar

`include "global.vh"

module xbar (ppv_0, ppv_1, ppv_2, ppv_3, ppv_4, in_0, in_1, in_2, in_3, in_4, out_0, out_1, out_2, out_3, out_4);

input  [`NUM_PORT-1:0]   ppv_0, ppv_1, ppv_2, ppv_3, ppv_4;
input  [`DATA_WIDTH-1:0] in_0, in_1, in_2, in_3, in_4;
output [`DATA_WIDTH-1:0] out_0, out_1, out_2, out_3, out_4;

wire [`LOG_NUM_PORT-1:0] sel_in [0:4];
wire [`LOG_NUM_PORT-1:0] sel_out [0:4];

outSelTrans outSelTranslation0 (ppv_0, sel_in[0]);
outSelTrans outSelTranslation1 (ppv_1, sel_in[1]);
outSelTrans outSelTranslation2 (ppv_2, sel_in[2]);
outSelTrans outSelTranslation3 (ppv_3, sel_in[3]);
outSelTrans outSelTranslation4 (ppv_4, sel_in[4]);

wire [`NUM_PORT-1:0] out_is_taken_by [0:4];
// Check which input win each port
genvar input_i, output_i;
generate
  for (output_i=0; output_i<5; output_i=output_i+1) 
    for (input_i=0; input_i<5; input_i=input_i+1) 
      assign out_is_taken_by [output_i][input_i] = (sel_in [input_i] == output_i) ? 1'b1 : 1'b0;
endgenerate

// Select the input flit for each output mux
outSelTrans outSelTranslation5 (out_is_taken_by[0], sel_out[0]);
outSelTrans outSelTranslation6 (out_is_taken_by[1], sel_out[1]);
outSelTrans outSelTranslation7 (out_is_taken_by[2], sel_out[2]);
outSelTrans outSelTranslation8 (out_is_taken_by[3], sel_out[3]);
outSelTrans outSelTranslation9 (out_is_taken_by[4], sel_out[4]);

mux5to1 # (`DATA_WIDTH) xbar_mux_0 (in_0, in_1, in_2, in_3, in_4, sel_out[0], out_0);
mux5to1 # (`DATA_WIDTH) xbar_mux_1 (in_0, in_1, in_2, in_3, in_4, sel_out[1], out_1);
mux5to1 # (`DATA_WIDTH) xbar_mux_2 (in_0, in_1, in_2, in_3, in_4, sel_out[2], out_2);
mux5to1 # (`DATA_WIDTH) xbar_mux_3 (in_0, in_1, in_2, in_3, in_4, sel_out[3], out_3);
mux5to1 # (`DATA_WIDTH) xbar_mux_4 (in_0, in_1, in_2, in_3, in_4, sel_out[4], out_4);

endmodule

