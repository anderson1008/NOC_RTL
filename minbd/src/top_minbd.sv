// minBD router top

`ifndef _TOP_MINBD_SV
`define _TOP_MINBD_SV
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"

module top_minbd (
clk,
n_rst,
din_n,
din_e,
din_s,
din_w,
din_l,
dout_n,
dout_e,
dout_s,
dout_w,
dout_l_1,
dout_l_2,
local_inject_gnt
);

input  clk, n_rst;
input  flit_ext_t din_n, din_e, din_s, din_w, din_l;
output flit_ext_t dout_n, dout_e, dout_s, dout_w, dout_l_1, dout_l_2;
output logic local_inject_gnt;

flit_int_t flit_in_0 [0:9];
flit_int_t flit_in_1 [0:9];
flit_int_t flit_in_2 [0:9];
flit_int_t flit_in_3 [0:9];
flit_int_t flit_in_l;
flit_ext_t r_din_n, r_din_e, r_din_s, r_din_w, r_din_l;


// A random number generator using 4-bit LFST
// The result should be flopped to reduce the critical path
// The logic which uses it does not care whether or not the number is current or from previous cycle

logic [2:0] rand_num, r_rand_num;

lfsr lfsr_inst (clk, n_rst, rand_num);

// Buffer input flits

`ifdef USE_REG_MACRO
`REG_SYNC_RST(clk, n_rst, r_rand_num, rand_num)
`REG_SYNC_RST(clk, n_rst, r_din_n, din_n)
`REG_SYNC_RST(clk, n_rst, r_din_e, din_e)
`REG_SYNC_RST(clk, n_rst, r_din_s, din_s)
`REG_SYNC_RST(clk, n_rst, r_din_w, din_w)
`REG_SYNC_RST(clk, n_rst, r_din_l, din_l)
`else
dff_sync_rst #(3) rand_dff (rand_num, clk, n_rst, 1'b1, r_rand_num);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_n (din_n, clk, n_rst, din_n.vld, r_din_n);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_e (din_e, clk, n_rst, din_e.vld, r_din_e);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_s (din_s, clk, n_rst, din_s.vld, r_din_s);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_w (din_w, clk, n_rst, din_w.vld, r_din_w);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_l (din_l, clk, n_rst, din_l.vld, r_din_l);
`endif

reg din_n_en, din_e_en, din_s_en, din_w_en, din_l_en;
always @ (posedge clk) begin
  din_n_en <= din_n.vld;
  din_e_en <= din_e.vld;
	din_s_en <= din_s.vld;
	din_w_en <= din_w.vld;
	din_l_en <= din_l.vld;
end

flit_ext_t w_din_n, w_din_e, w_din_s, w_din_w, w_din_l;
mux2to1 #(`WIDTH_FLIT_EXT) mux_din_n ({`WIDTH_FLIT_EXT{1'b0}}, r_din_n, din_n_en, w_din_n);
mux2to1 #(`WIDTH_FLIT_EXT) mux_din_e ({`WIDTH_FLIT_EXT{1'b0}}, r_din_e, din_e_en, w_din_e);
mux2to1 #(`WIDTH_FLIT_EXT) mux_din_s ({`WIDTH_FLIT_EXT{1'b0}}, r_din_s, din_s_en, w_din_s);
mux2to1 #(`WIDTH_FLIT_EXT) mux_din_w ({`WIDTH_FLIT_EXT{1'b0}}, r_din_w, din_w_en, w_din_w);
mux2to1 #(`WIDTH_FLIT_EXT) mux_din_l ({`WIDTH_FLIT_EXT{1'b0}}, r_din_l, din_l_en, w_din_l);
 
 
// Route computation

wire [`NUM_DIR-1:0] ppv [0:4];

rc #(`CORD_X, `CORD_Y) rc_n (w_din_n.dst_x, w_din_n.dst_y, ppv[0]);
rc #(`CORD_X, `CORD_Y) rc_e (w_din_e.dst_x, w_din_e.dst_y, ppv[1]);
rc #(`CORD_X, `CORD_Y) rc_s (w_din_s.dst_x, w_din_s.dst_y, ppv[2]);
rc #(`CORD_X, `CORD_Y) rc_w (w_din_w.dst_x, w_din_w.dst_y, ppv[3]);
rc #(`CORD_X, `CORD_Y) rc_l (w_din_l.dst_x, w_din_l.dst_y, ppv[4]);

// Assign sliver flit 
//   MinBD paper assigns sliver flit in second stage. 
//   But the arbiter in the first stage needs this information.
//   This implementation assign sliver flit here.
//   The implication is that the local injected flit will be an ordinary flit

wire [`NUM_DIR-2:0] silver_vec;

pick_1out4_rand find_silver (
.data_in  ({w_din_w.vld && ~w_din_w.golden, w_din_s.vld && ~w_din_s.golden, w_din_e.vld && ~w_din_e.golden, w_din_n.vld && ~w_din_n.golden}),
.rand_num (r_rand_num[1:0]),
.data_out (silver_vec)
);


// Form internal flit

assign flit_in_0 [0] = {1'b0, ppv[0], silver_vec[0], w_din_n};
assign flit_in_1 [0] = {1'b0, ppv[1], silver_vec[1], w_din_e};
assign flit_in_2 [0] = {1'b0, ppv[2], silver_vec[2], w_din_s};
assign flit_in_3 [0] = {1'b0, ppv[3], silver_vec[3], w_din_w};
assign flit_in_l = {1'b0, ppv[4], 1'b0, w_din_l};


// Ejector 1

flit_int_t dout_local_1;

eject eject_st1 (
.rand_num       (r_rand_num-1'b1),
.din_0          (flit_in_0[0]),
.din_1          (flit_in_1[0]),
.din_2          (flit_in_2[0]),
.din_3          (flit_in_3[0]),
.dout_0         (flit_in_0[1]),
.dout_1         (flit_in_1[1]),
.dout_2         (flit_in_2[1]),
.dout_3         (flit_in_3[1]),
.dout_local     (dout_local_1)
);

// Ejector 2

flit_int_t dout_local_2;

eject eject_st2 (
.rand_num       (r_rand_num-1'b1),
.din_0          (flit_in_0[1]),
.din_1          (flit_in_1[1]),
.din_2          (flit_in_2[1]),
.din_3          (flit_in_3[1]),
.dout_0         (flit_in_0[2]),
.dout_1         (flit_in_1[2]),
.dout_2         (flit_in_2[2]),
.dout_3         (flit_in_3[2]),
.dout_local     (dout_local_2)
);

// Redirect to side buffer

logic      starve, redirect_gnt, full, empty;
flit_int_t flit_redirected;

redirect redirect_inst(
.rand_num       (r_rand_num-1'b1),
.starve         (starve),
.full           (full),
.din_0          (flit_in_0[2]),
.din_1          (flit_in_1[2]),
.din_2          (flit_in_2[2]),
.din_3          (flit_in_3[2]),
.dout_0         (flit_in_0[3]),
.dout_1         (flit_in_1[3]),
.dout_2         (flit_in_2[3]),
.dout_3         (flit_in_3[3]),
.dout_redirected(flit_redirected),
.redirect_gnt   (redirect_gnt) // all channels are full and a flit is selected to be redirected to side buffer, given side buffer is not full
);

// Inject flit from the side buffer 

flit_int_t side_buf_inj_dat;
logic side_buf_inject_gnt;

inject side_buf_inject(
.inject_req     (~empty),
.din_inject     (side_buf_inj_dat),
.din_0          (flit_in_0[3]),
.din_1          (flit_in_1[3]),
.din_2          (flit_in_2[3]),
.din_3          (flit_in_3[3]),
.dout_0         (flit_in_0[4]),
.dout_1         (flit_in_1[4]),
.dout_2         (flit_in_2[4]),
.dout_3         (flit_in_3[4]),
.inject_gnt     (side_buf_inject_gnt)  
);

// Local injection

logic local_inject_gnt_out;

inject local_inject_inst (
.inject_req      (flit_in_l.vld),
.din_inject      (flit_in_l),
.din_0           (flit_in_0[4]),
.din_1           (flit_in_1[4]),
.din_2           (flit_in_2[4]),
.din_3           (flit_in_3[4]),
.dout_0          (flit_in_0[5]),
.dout_1          (flit_in_1[5]),
.dout_2          (flit_in_2[5]),
.dout_3          (flit_in_3[5]),
.inject_gnt      (local_inject_gnt_out)
);


// Pipeline Stage 1

`ifdef USE_REG_MACRO
`REG_SYNC_RST(clk, n_rst, flit_in_0[6], flit_in_0[5])
`REG_SYNC_RST(clk, n_rst, flit_in_1[6], flit_in_1[5])
`REG_SYNC_RST(clk, n_rst, flit_in_2[6], flit_in_2[5])
`REG_SYNC_RST(clk, n_rst, flit_in_3[6], flit_in_3[5])
`else
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_st1_0 (flit_in_0[5], clk, n_rst, flit_in_0[5].vld, flit_in_0[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_st1_1 (flit_in_1[5], clk, n_rst, flit_in_1[5].vld, flit_in_1[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_st1_2 (flit_in_2[5], clk, n_rst, flit_in_2[5].vld, flit_in_2[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_st1_3 (flit_in_3[5], clk, n_rst, flit_in_3[5].vld, flit_in_3[6]);
`endif

// Propogate the valid bit to the next pipeline stage
reg  [3:0] r_st1_en;
always @ (posedge clk) begin
  r_st1_en [0] <= flit_in_0[5].vld;
  r_st1_en [1] <= flit_in_1[5].vld;
  r_st1_en [2] <= flit_in_2[5].vld;
  r_st1_en [3] <= flit_in_3[5].vld;
end

// Select the data propogated to the next pipeline stage
mux2to1 #(`WIDTH_FLIT_INT) mux_st1_sel_0 ({`WIDTH_FLIT_INT{1'b0}}, flit_in_0[6], r_st1_en[0], flit_in_0[7]);
mux2to1 #(`WIDTH_FLIT_INT) mux_st1_sel_1 ({`WIDTH_FLIT_INT{1'b0}}, flit_in_1[6], r_st1_en[1], flit_in_1[7]);
mux2to1 #(`WIDTH_FLIT_INT) mux_st1_sel_2 ({`WIDTH_FLIT_INT{1'b0}}, flit_in_2[6], r_st1_en[2], flit_in_2[7]);
mux2to1 #(`WIDTH_FLIT_INT) mux_st1_sel_3 ({`WIDTH_FLIT_INT{1'b0}}, flit_in_3[6], r_st1_en[3], flit_in_3[7]);

// Permuation 

permutation_network permutation_network (
.rand_num        (r_rand_num-1'b1),
.din_0           (flit_in_0[7]),
.din_1           (flit_in_1[7]),
.din_2           (flit_in_2[7]),
.din_3           (flit_in_3[7]),
.dout_0          (flit_in_0[8]),
.dout_1          (flit_in_1[8]),
.dout_2          (flit_in_2[8]),
.dout_3          (flit_in_3[8])
);

// Side buffer store

flit_int_t       eject_to_side_buf;

side_buffer side_buffer_inst (
.clk             (clk),
.n_rst           (n_rst),
// redirect stage
.din_redirect    (flit_redirected),
.redirect_gnt    (redirect_gnt), 
.deflect_to_side_buf_vld (deflect_to_side_buf_vld),
// eject_to_side_buf stage   
.din_eject       (eject_to_side_buf),  
// side_buf_inject
.dout_inject     (side_buf_inj_dat),
.inject_gnt      (side_buf_inject_gnt),
// flag
.starve          (starve),
.full            (full),
.empty           (empty)
);

// Side buffer eject
// Pick one deflected flit and store in the side buffer
eject_to_side_buf eject_to_side_buf_inst (
.rand_num        (r_rand_num-1'b1),
.full            (full),
.redirect_gnt    (redirect_gnt),
.din_0           (flit_in_0[8]),
.din_1           (flit_in_1[8]),
.din_2           (flit_in_2[8]),
.din_3           (flit_in_3[8]),
.dout_0          (flit_in_0[9]),
.dout_1          (flit_in_1[9]),
.dout_2          (flit_in_2[9]),
.dout_3          (flit_in_3[9]),
.dout_side_buf   (eject_to_side_buf),
.deflect_to_side_buf_vld (deflect_to_side_buf_vld)
);

// output pipeline
flit_ext_t w_dout_n, w_dout_e, w_dout_s, w_dout_w, w_dout_local_1, w_dout_local_2;
`ifdef USR_REG_MACRO
`REG_SYNC_RST(clk, n_rst, dout_n, flit_in_0[9][`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_s, flit_in_1[9][`WIDTH_FLIT_EXT-1:0]) // this port is twisted
`REG_SYNC_RST(clk, n_rst, dout_e, flit_in_2[9][`WIDTH_FLIT_EXT-1:0]) // this port is twisted
`REG_SYNC_RST(clk, n_rst, dout_w, flit_in_3[9][`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_l_1, dout_local_1[`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_l_2, dout_local_2[`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, local_inject_gnt, local_inject_gnt_out)
`else
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_l_1 (dout_local_1[`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_local_1.vld, w_dout_local_1);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_l_2 (dout_local_2[`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_local_2.vld, w_dout_local_2);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_n   (flit_in_0[9][`WIDTH_FLIT_EXT-1:0], clk, n_rst, flit_in_0[9].vld, w_dout_n);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_s   (flit_in_1[9][`WIDTH_FLIT_EXT-1:0], clk, n_rst, flit_in_1[9].vld, w_dout_s);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_e   (flit_in_2[9][`WIDTH_FLIT_EXT-1:0], clk, n_rst, flit_in_2[9].vld, w_dout_e);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_w   (flit_in_3[9][`WIDTH_FLIT_EXT-1:0], clk, n_rst, flit_in_3[9].vld, w_dout_w);
dff_sync_rst #(1) output_reg_local_inj_gnt (local_inject_gnt_out, clk, n_rst, 1'b1, local_inject_gnt);
`endif

reg  dout_n_en, dout_e_en, dout_s_en, dout_w_en, dout_local_1_en, dout_local_2_en;
always @ (posedge clk) begin
  dout_n_en <= flit_in_0[9].vld;
  dout_s_en <= flit_in_1[9].vld;
  dout_e_en <= flit_in_2[9].vld;
  dout_w_en <= flit_in_3[9].vld;
	dout_local_1_en <= dout_local_1.vld;
	dout_local_2_en <= dout_local_2.vld;
end

mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_n ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_n, dout_n_en, dout_n);
mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_s ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_s, dout_s_en, dout_s);
mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_e ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_e, dout_e_en, dout_e);
mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_w ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_w, dout_w_en, dout_w);
mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_local_1 ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_local_1, dout_local_1_en, dout_l_1);
mux2to1 #(`WIDTH_FLIT_EXT) mux_out_sel_local_2 ({`WIDTH_FLIT_EXT{1'b0}}, w_dout_local_2, dout_local_2_en, dout_l_2);

endmodule

`endif