`timescale 1ns / 1ps

`include "global.vh"

// Permutation Network
module permutationNetwork #(parameter FULL_SORT=0) ( 
  data0, 
  data1, 
  data2, 
  data3, 
  ppv0, 
  ppv1, 
  ppv2, 
  ppv3, 
  rank0_data, 
  rank1_data,
  rank2_data, 
  rank3_data, 
  rank0_ppv,
  rank1_ppv,
  rank2_ppv,
  rank3_ppv
);

input  [`DATA_WIDTH-1:0] data0, data1, data2, data3;
input  [`NUM_PORT-1:0]   ppv0, ppv1, ppv2, ppv3;
output [`DATA_WIDTH-1:0] rank0_data, rank1_data, rank2_data, rank3_data;
output [`NUM_PORT-1:0]   rank0_ppv, rank1_ppv, rank2_ppv, rank3_ppv;


wire   [`PERM_WIDTH-1:0] w_out        [3:0];
wire   [`TIME_WIDTH-1:0] time_stamp   [3:0];

assign time_stamp[0]=data0[`TIME_POS];
assign time_stamp[1]=data1[`TIME_POS];
assign time_stamp[2]=data2[`TIME_POS];
assign time_stamp[3]=data3[`TIME_POS];

generate
  if (FULL_SORT == 0) begin
    wire   [`PERM_WIDTH-1:0] swapFlit     [1:0];
    wire   [`PERM_WIDTH-1:0] straightFlit [1:0];
    wire   [3:0]             swap;
    // (1: downward sort; 0: upward sort)
    arbiterPN arbiterPN00 (time_stamp[0], time_stamp[1], 1'b0, swap[0]);
    arbiterPN arbiterPN01 (time_stamp[2], time_stamp[3], 1'b1, swap[1]);
    arbiterPN arbiterPN10 (straightFlit[0][`TIME_POS], swapFlit[1][`TIME_POS], 1'b0, swap[2]);
    arbiterPN arbiterPN11 (swapFlit[0][`TIME_POS], straightFlit[1][`TIME_POS], 1'b0, swap[3]);

    permuterBlock # (`PERM_WIDTH) PN00({ppv0,data0}, {ppv1,data1}, swap[0], straightFlit[0], swapFlit[0]);
    permuterBlock # (`PERM_WIDTH) PN01({ppv2,data2}, {ppv3,data3}, swap[1], swapFlit[1], straightFlit[1]);
    permuterBlock # (`PERM_WIDTH) PN10({straightFlit[0]}, {swapFlit[1]}, swap[2], w_out[0], w_out[1]);
    permuterBlock # (`PERM_WIDTH) PN11({swapFlit[0]}, {straightFlit[1]}, swap[3], w_out[2], w_out[3]);
  end
  else begin
    wire   [`PERM_WIDTH-1:0] swapFlit     [3:0];
    wire   [`PERM_WIDTH-1:0] straightFlit [3:0];
    wire   [5:0]             swap;
    // (1: downward sort; 0: upward sort)
    arbiterPN arbiterPN00 (time_stamp[0], time_stamp[1], 1'b0, swap[0]);
    arbiterPN arbiterPN01 (time_stamp[2], time_stamp[3], 1'b1, swap[1]);
    arbiterPN arbiterPN10 (straightFlit[0][`TIME_POS], swapFlit[1][`TIME_POS], 1'b0, swap[2]);
    arbiterPN arbiterPN11 (swapFlit[0][`TIME_POS], straightFlit[1][`TIME_POS], 1'b0, swap[3]);
    arbiterPN arbiterPN20 (straightFlit[2][`TIME_POS], swapFlit[3][`TIME_POS], 1'b0, swap[4]);
    arbiterPN arbiterPN21 (swapFlit[2][`TIME_POS], straightFlit[3][`TIME_POS], 1'b0, swap[5]);
    
    permuterBlock # (`PERM_WIDTH) PN00({ppv0,data0}, {ppv1,data1}, swap[0], straightFlit[0], swapFlit[0]);
    permuterBlock # (`PERM_WIDTH) PN01({ppv2,data2}, {ppv3,data3}, swap[1], swapFlit[1], straightFlit[1]);
    permuterBlock # (`PERM_WIDTH) PN10(straightFlit[0], swapFlit[1], swap[2], straightFlit[2], swapFlit[2]);
    permuterBlock # (`PERM_WIDTH) PN11(swapFlit[0], straightFlit[1], swap[3], swapFlit[3], straightFlit[3]);  
    permuterBlock # (`PERM_WIDTH) PN20(straightFlit[2], swapFlit[3], swap[4], w_out[0], w_out[1]);
    permuterBlock # (`PERM_WIDTH) PN21(swapFlit[2], straightFlit[3], swap[5], w_out[2], w_out[3]); 
  end
endgenerate

assign rank0_ppv = w_out[0][`PPV_POS];
assign rank1_ppv = w_out[1][`PPV_POS];
assign rank2_ppv = w_out[2][`PPV_POS];
assign rank3_ppv = w_out[3][`PPV_POS];
assign rank0_data = w_out[0][`DATA_POS];
assign rank1_data = w_out[1][`DATA_POS];
assign rank2_data = w_out[2][`DATA_POS];
assign rank3_data = w_out[3][`DATA_POS];

endmodule