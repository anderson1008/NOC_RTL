`timescale 1ns / 1ps

`include "global.vh"

module top_bless # (
  parameter CORD_X = `CORD_X,
  parameter CORD_Y = `CORD_Y
)(
	clk,
	n_rst,
	data_in_0,
	data_in_1,
	data_in_2,
	data_in_3,
	data_in_4,
	data_out_0,
	data_out_1,
	data_out_2,
	data_out_3,
	data_out_4
);

input  clk, n_rst;
input  [`DATA_WIDTH-1:0] data_in_0, data_in_1, data_in_2, data_in_3, data_in_4;
output [`DATA_WIDTH-1:0] data_out_0, data_out_1, data_out_2, data_out_3, data_out_4;

//buffer the input
wire [`DATA_WIDTH-1:0] r_data [0:`NUM_PORT-1];
dff_async_reset #(`DATA_WIDTH) in_pc_0(data_in_0, clk, n_rst, r_data[0]);
dff_async_reset #(`DATA_WIDTH) in_pc_1(data_in_1, clk, n_rst, r_data[1]);
dff_async_reset #(`DATA_WIDTH) in_pc_2(data_in_2, clk, n_rst, r_data[2]);
dff_async_reset #(`DATA_WIDTH) in_pc_3(data_in_3, clk, n_rst, r_data[3]);
dff_async_reset #(`DATA_WIDTH) in_pc_4(data_in_4, clk, n_rst, r_data[4]);

// seperate the field 
wire [`DST_WIDTH-1:0] dst [0:`NUM_PORT-1];

genvar j;
generate
	for (j=0; j<`NUM_PORT; j=j+1) begin : split_field
		assign dst [j] = r_data [j][`DST_POS];
	end 
endgenerate     

// Router computation
genvar k;
wire [`NUM_PORT-1:0] ppv [4:0];
generate 
for (k=0; k<5; k=k+1) begin : RC
	rc #(
	.CORD_X      (CORD_X),
	.CORD_Y      (CORD_Y)
	) rc_inst(
	.dst                    (dst[k]), 
	.preferPortVector       (ppv[k])
);
end
endgenerate
	
// local flit injection
wire [`PC_INDEX_WIDTH-1:0] num_flit_in, has_eject;	
wire [`NUM_PORT-1:0]   sorted_ppv [0:4];
wire [`DATA_WIDTH-1:0] sorted_data [0:4];
wire grant_inject;

assign num_flit_in    = r_data[0][`VLD_POS] + r_data[1][`VLD_POS] + r_data[2][`VLD_POS] + r_data[3][`VLD_POS];
assign has_eject      = ppv[0][4] | ppv[1][4] | ppv[2][4] | ppv[3][4];
assign grant_inject   = ((num_flit_in - has_eject) < 4) ? 1'b1 : 1'b0;
assign sorted_data[4] = grant_inject ? r_data[4] : 'h0;
assign sorted_ppv [4] = grant_inject ? ppv[4]    : 'h0;	

// Permutation Sorting Network
permutationNetwork #(`FULL_SORT) permutationSort(    
.data0       (r_data[0]),
.data1       (r_data[1]),
.data2       (r_data[2]),
.data3       (r_data[3]),
.ppv0        (ppv[0]), 
.ppv1        (ppv[1]), 
.ppv2        (ppv[2]), 
.ppv3        (ppv[3]),
.rank0_data  (sorted_data[0]),
.rank1_data  (sorted_data[1]), 
.rank2_data  (sorted_data[2]), 
.rank3_data  (sorted_data[3]),
.rank0_ppv   (sorted_ppv[0]),
.rank1_ppv   (sorted_ppv[1]),
.rank2_ppv   (sorted_ppv[2]),
.rank3_ppv   (sorted_ppv[3])
);

// ST1 pipeline buffer
wire [`DATA_WIDTH-1:0] r_st1_data [4:0];
wire [`NUM_PORT-1:0]   r_st1_ppv  [4:0];

genvar m;    
generate
	for (m=0; m<5; m=m+1) begin: ST1_BUF 
		dff_async_reset #(`DATA_WIDTH) st1_buf_data (sorted_data[m], clk, n_rst, r_st1_data[m]);
		dff_async_reset #(`NUM_PORT)   st1_buf_ppv  (sorted_ppv[m], clk, n_rst, r_st1_ppv[m]);
	end
endgenerate 

wire [`NUM_PORT-1:0] allocPV [4:0];   
swAlloc swAlloc(
.ppv_0          (r_st1_ppv[0]),
.ppv_1          (r_st1_ppv[1]),
.ppv_2          (r_st1_ppv[2]),
.ppv_3          (r_st1_ppv[3]),
.ppv_4          (r_st1_ppv[4]),
.allocPV_0      (allocPV[0]),
.allocPV_1      (allocPV[1]),
.allocPV_2      (allocPV[2]),
.allocPV_3      (allocPV[3]),
.allocPV_4      (allocPV[4])
);          

wire [`DATA_WIDTH-1:0] xbar_out [0:4];

xbar xbar(
.in_0           (r_st1_data[0]),
.in_1           (r_st1_data[1]),
.in_2           (r_st1_data[2]),
.in_3           (r_st1_data[3]),
.in_4           (r_st1_data[4]),
.ppv_0          (allocPV[0]),
.ppv_1          (allocPV[1]),
.ppv_2          (allocPV[2]),
.ppv_3          (allocPV[3]),
.ppv_4          (allocPV[4]),
.out_0          (xbar_out[0]),
.out_1          (xbar_out[1]),
.out_2          (xbar_out[2]),
.out_3          (xbar_out[3]),
.out_4          (xbar_out[4])
);

dff_async_reset #(`DATA_WIDTH) st2_buf_data_0 (xbar_out[0], clk, n_rst, data_out_0);
dff_async_reset #(`DATA_WIDTH) st2_buf_data_1 (xbar_out[1], clk, n_rst, data_out_1);
dff_async_reset #(`DATA_WIDTH) st2_buf_data_2 (xbar_out[2], clk, n_rst, data_out_2);
dff_async_reset #(`DATA_WIDTH) st2_buf_data_3 (xbar_out[3], clk, n_rst, data_out_3);
dff_async_reset #(`DATA_WIDTH) st2_buf_data_4 (xbar_out[4], clk, n_rst, data_out_4);

endmodule



