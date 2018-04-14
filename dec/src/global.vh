// Global Variable
`ifndef _GLOBAL_PARA_V
`define _GLOBAL_PARA_V

// Port Arragement
// 5-BYPASS 4-LOCAL; 3-N; 2-S; 1-E; 0-W;

//Packet format (on the link)
// [requesterID mshrID pktSize FLITID TIME POS_X POS_Y VLD]
// [     6        5       3      3     8     3    3     1]  size = 32 

// [PV requesterID mshrID pktSize FLITID TIME POS_X POS_Y VLD]
// [5       6        5       3      3     8     3    3     1]  size = 37 


`define CORD_X `WIDTH_COORDINATE'd3
`define CORD_Y `WIDTH_COORDINATE'd3
`define X_COORD `WIDTH_COORDINATE +: `WIDTH_COORDINATE
`define Y_COORD 0 +: `WIDTH_COORDINATE
`define SIZE_NETWORK 4  //Max=8 ???
`define NUM_PORT 6  // Include Pypass
`define NUM_CHANNEL  5
`define LOG_NUM_PORT 3 // = Celling (log2 (NUM_PORT))
`define WIDTH_DATA 256
`define WIDTH_CTRL 32
`define WIDTH_PORT `WIDTH_DATA+`WIDTH_CTRL
`define WIDTH_PV 5 // width of productive vector
`define WIDTH_INTERNAL_PV `WIDTH_PORT+`WIDTH_PV // has 1-valid bit + 5-bit PV
`define WIDTH_XBAR `WIDTH_PORT

`define WIDTH_TIME 8
`define WIDTH_COORDINATE 3 // support up to 8 nodes in each dimension
`define WIDTH_FLITID 3
`define MAX_TIME 127

`define POS_VALID  `WIDTH_DATA
`define END_VALID  `WIDTH_DATA + 1
`define POS_Y_DST  `END_VALID +: `WIDTH_COORDINATE
`define END_Y_DST  `END_VALID + `WIDTH_COORDINATE
`define POS_X_DST  `END_Y_DST +: `WIDTH_COORDINATE
`define END_X_DST  `END_Y_DST + `WIDTH_COORDINATE
`define POS_TIME   `END_X_DST +: `WIDTH_TIME
`define END_TIME   `END_X_DST + `WIDTH_TIME
`define POS_FLITID `END_TIME +: `WIDTH_FLITID
`define END_FLITID `END_TIME + `WIDTH_FLITID
`define POS_PKTSZE `END_FLITID +: `WIDTH_FLITID
`define END_PKTSZE `END_FLITID + `WIDTH_FLITID
`define POS_PV `WIDTH_INTERNAL_PV-1 : `WIDTH_INTERNAL_PV-`WIDTH_PV

`endif