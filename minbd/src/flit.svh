// flit definition
`ifndef _FLIT_SV
`define _FLIT_SV
`include "global.svh"

//flit header format (on the link)
// [golden requesterID mshrID pktSize FLITID DST_X DST_Y VLD]
// [  1       6        5       3      3      3    3     1]  size = 25

typedef struct packed{
  logic                      golden;
  logic [`WIDTH_REQID-1:0]   requester_id;
	logic [`WIDTH_MSHRID-1:0]  mshr_id;
	logic [`WIDTH_PKTSZ-1:0]   pkt_size;
	logic [`WIDTH_PKTSZ-1:0]   flit_id;
	logic [`WIDTH_COORD-1:0]   dst_x;
	logic [`WIDTH_COORD-1:0]   dst_y;
	logic                      vld;
	logic [`WIDTH_DATA-1:0]    payload;
} flit_ext_t;


//flit header format (internally)
// [deflect ppv silver golden requesterID mshrID pktSize FLITID DST_X DST_Y VLD]
// [   1     5    1      1       6        5       3      3      3    3     1]  size = 32

typedef struct packed {
    logic                      deflect;
    logic [`NUM_DIR-1:0]       ppv;	
    logic                      silver;
    logic                      golden;
    logic [`WIDTH_REQID-1:0]   requester_id;
    logic [`WIDTH_MSHRID-1:0]  mshr_id;
    logic [`WIDTH_PKTSZ-1:0]   pkt_size;
    logic [`WIDTH_PKTSZ-1:0]  flit_id;
    logic [`WIDTH_COORD-1:0]     dst_x;
    logic [`WIDTH_COORD-1:0]     dst_y;
    logic                      vld;
    logic [`WIDTH_DATA-1:0]    payload;
} flit_int_t;

`endif