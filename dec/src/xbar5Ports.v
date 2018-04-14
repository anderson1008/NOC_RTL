`timescale 1ns / 1ps

`include "global.vh"

// 5 ports Xbar 
module xbar5Ports (allocVector, in_0, in_1, in_2, in_3, in_4, out_0, out_1, out_2, out_3, out_4);

input [`NUM_CHANNEL*`NUM_CHANNEL-1:0] allocVector;
input  [`WIDTH_XBAR-1:0] in_0, in_1, in_2, in_3, in_4;
output [`WIDTH_XBAR-1:0] out_0, out_1, out_2, out_3, out_4;

wire [`NUM_CHANNEL-1:0] alloc [0 : `NUM_CHANNEL-1];
wire [`LOG_NUM_PORT-1:0] sel_in [0:`NUM_CHANNEL-1];
wire [`LOG_NUM_PORT-1:0] sel_out [0:`NUM_CHANNEL-1];

// Port allocation needs to guarantee that each flit only obtains one ports
// Xbar only forward it to the right output port
genvar j;
generate 
   for (j=0; j<`NUM_CHANNEL; j=j+1) begin : outSelTranslate
      assign alloc[j] = allocVector [j*`NUM_CHANNEL+:`NUM_CHANNEL];
      outSelTrans outSelTranslation(alloc[j], sel_in[j]);
    end
endgenerate

wire [`NUM_CHANNEL-1:0] out_is_taken_by [0:4];
// Check which input win each port
genvar input_i, output_i;
generate
  for (output_i=0; output_i<`NUM_CHANNEL; output_i=output_i+1) 
    for (input_i=0; input_i<`NUM_CHANNEL; input_i=input_i+1) 
      assign out_is_taken_by [output_i][input_i] = (sel_in [input_i] == output_i) ? 1'b1 : 1'b0;
endgenerate

// Select the input flit for each output mux
outSelTrans outSelTranslation5 (out_is_taken_by[0], sel_out[0]);
outSelTrans outSelTranslation6 (out_is_taken_by[1], sel_out[1]);
outSelTrans outSelTranslation7 (out_is_taken_by[2], sel_out[2]);
outSelTrans outSelTranslation8 (out_is_taken_by[3], sel_out[3]);
outSelTrans outSelTranslation9 (out_is_taken_by[4], sel_out[4]);

mux5to1 # (`WIDTH_XBAR) xbar_mux_0 (in_0, in_1, in_2, in_3, in_4, sel_out[0], out_0);
mux5to1 # (`WIDTH_XBAR) xbar_mux_1 (in_0, in_1, in_2, in_3, in_4, sel_out[1], out_1);
mux5to1 # (`WIDTH_XBAR) xbar_mux_2 (in_0, in_1, in_2, in_3, in_4, sel_out[2], out_2);
mux5to1 # (`WIDTH_XBAR) xbar_mux_3 (in_0, in_1, in_2, in_3, in_4, sel_out[3], out_3);
mux5to1 # (`WIDTH_XBAR) xbar_mux_4 (in_0, in_1, in_2, in_3, in_4, sel_out[4], out_4);

endmodule