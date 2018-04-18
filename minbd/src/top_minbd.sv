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

flit_int_t flit_in_0 [0:8];
flit_int_t flit_in_1 [0:8];
flit_int_t flit_in_2 [0:8];
flit_int_t flit_in_3 [0:8];
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
dff_sync_rst #(3) rand_dff (rand_num, clk, n_rst, r_rand_num);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_n (din_n, clk, n_rst, r_din_n);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_e (din_e, clk, n_rst, r_din_e);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_s (din_s, clk, n_rst, r_din_s);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_w (din_w, clk, n_rst, r_din_w);
dff_sync_rst #(`WIDTH_FLIT_EXT) input_reg_1_l (din_l, clk, n_rst, r_din_l);
`endif

// Route computation

wire [`NUM_DIR-1:0] ppv [0:4];

rc #(`CORD_X, `CORD_Y) rc_n (r_din_n.dst_x, r_din_n.dst_y, ppv[0]);
rc #(`CORD_X, `CORD_Y) rc_e (r_din_e.dst_x, r_din_e.dst_y, ppv[1]);
rc #(`CORD_X, `CORD_Y) rc_s (r_din_s.dst_x, r_din_s.dst_y, ppv[2]);
rc #(`CORD_X, `CORD_Y) rc_w (r_din_w.dst_x, r_din_w.dst_y, ppv[3]);
rc #(`CORD_X, `CORD_Y) rc_l (r_din_l.dst_x, r_din_l.dst_y, ppv[4]);

// Assign sliver flit 
//   MinBD paper assigns sliver flit in second stage. 
//   But the arbiter in the first stage needs this information.
//   This implementation assign sliver flit here.
//   The implication is that the local injected flit will be an ordinary flit

wire [`NUM_DIR-2:0] silver_vec;

pick_1out4_rand find_silver (
.data_in  ({r_din_w.vld && ~r_din_w.golden, r_din_s.vld && ~r_din_s.golden, r_din_e.vld && ~r_din_e.golden, r_din_n.vld && ~r_din_n.golden}),
.rand_num (r_rand_num-1'b1),
.data_out (silver_vec)
);


// Form internal flit

assign flit_in_0 [0] = {1'b0, ppv[0], silver_vec[0], r_din_n};
assign flit_in_1 [0] = {1'b0, ppv[1], silver_vec[1], r_din_e};
assign flit_in_2 [0] = {1'b0, ppv[2], silver_vec[2], r_din_s};
assign flit_in_3 [0] = {1'b0, ppv[3], silver_vec[3], r_din_w};
assign flit_in_l = {1'b0, ppv[4], 1'b0, r_din_l};


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
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_1_0 (flit_in_0[5], clk, n_rst, flit_in_0[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_1_1 (flit_in_1[5], clk, n_rst, flit_in_1[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_1_2 (flit_in_2[5], clk, n_rst, flit_in_2[6]);
dff_sync_rst #(`WIDTH_FLIT_INT) pipeline_reg_1_3 (flit_in_3[5], clk, n_rst, flit_in_3[6]);
`endif

// Permuation 

permutation_network permutation_network (
.rand_num        (r_rand_num-1'b1),
.din_0           (flit_in_0[6]),
.din_1           (flit_in_1[6]),
.din_2           (flit_in_2[6]),
.din_3           (flit_in_3[6]),
.dout_0          (flit_in_0[7]),
.dout_1          (flit_in_1[7]),
.dout_2          (flit_in_2[7]),
.dout_3          (flit_in_3[7])
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
.din_0           (flit_in_0[7]),
.din_1           (flit_in_1[7]),
.din_2           (flit_in_2[7]),
.din_3           (flit_in_3[7]),
.dout_0          (flit_in_0[8]),
.dout_1          (flit_in_1[8]),
.dout_2          (flit_in_2[8]),
.dout_3          (flit_in_3[8]),
.dout_side_buf   (eject_to_side_buf),
.deflect_to_side_buf_vld (deflect_to_side_buf_vld)
);

// output pipeline
`ifdef USR_REG_MACRO
`REG_SYNC_RST(clk, n_rst, dout_n, flit_in_0[8][`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_s, flit_in_1[8][`WIDTH_FLIT_EXT-1:0]) // this port is twisted
`REG_SYNC_RST(clk, n_rst, dout_e, flit_in_2[8][`WIDTH_FLIT_EXT-1:0]) // this port is twisted
`REG_SYNC_RST(clk, n_rst, dout_w, flit_in_3[8][`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_l_1, dout_local_1[`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, dout_l_2, dout_local_2[`WIDTH_FLIT_EXT-1:0])
`REG_SYNC_RST(clk, n_rst, local_inject_gnt, local_inject_gnt_out)
`else
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_l_1 (dout_local_1[`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_l_1);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_l_2 (dout_local_2[`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_l_2);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_n   (flit_in_0[8][`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_n);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_s   (flit_in_1[8][`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_s);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_e   (flit_in_2[8][`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_e);
dff_sync_rst #(`WIDTH_FLIT_EXT) output_reg_w   (flit_in_3[8][`WIDTH_FLIT_EXT-1:0], clk, n_rst, dout_w);
dff_sync_rst #(1) output_reg_local_inj_gnt (local_inject_gnt_out, clk, n_rst, local_inject_gnt);
`endif

endmodule

`endif