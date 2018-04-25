// Global Variable
`ifndef _GLOBAL_SVH
`define _GLOBAL_SVH

// Port Arragement
// 5-BYPASS 4-LOCAL; 3-N; 2-S; 1-E; 0-W;


`define WIDTH_DATA       256
`define WIDTH_HEADER     25	
`define WIDTH_REQID      6
`define NUM_DIR          5
`define WIDTH_MSHRID     5
`define WIDTH_PKTSZ      3
`define WIDTH_COORD      3
`define WIDTH_FLIT_EXT   `WIDTH_DATA + `WIDTH_HEADER
`define WIDTH_FLIT_INT   `WIDTH_DATA + `WIDTH_HEADER + `NUM_DIR + 2
`define MUX_DATA_T       flit_int_t

`define CORD_X           3
`define CORD_Y           3
`define SIDE_BUF_CNT_TH  1
`define DEPTH_SIDE_BUF   1
//`define USE_REG_MACRO    1 // Using regiter macro prevents tool from adding registers as a module

`define MUX2TO1(din_0, din_1, sel, dout) \
  assign dout = sel ? din_1 : din_0;
	
`define DEMUX1TO2(din, sel, dout_0, dout_1) \
  assign dout_0 = sel ? 'h0 : din; \
  assign dout_1 = sel ? din : 'h0;   
 
`define REG_SYNC_RST(clk, n_rst, q, d) \
  always @ (posedge clk or negedge n_rst) begin \
	  if (n_rst == 1'b0) q <= 'h0; \
		else q <= d; \
  end
 
`endif
