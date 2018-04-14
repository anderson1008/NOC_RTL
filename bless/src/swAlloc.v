`timescale 1ns / 1ps

`include "global.vh"

module swAlloc (
ppv_0,
ppv_1,
ppv_2,
ppv_3,
ppv_4,
allocPV_0,
allocPV_1,
allocPV_2,
allocPV_3,
allocPV_4
);

input  [`NUM_PORT-1:0] ppv_0, ppv_1, ppv_2, ppv_3, ppv_4;
output [`NUM_PORT-1:0] allocPV_0, allocPV_1, allocPV_2, allocPV_3, allocPV_4; 

wire   [`NUM_PORT-1:0] w_availPort [0:3];

seqPortAlloc rank0PortAlloc(
.availPortVector_in      (5'b11111),
.ppv                     (ppv_0),
.allocatedPortVector     (allocPV_0),
.availPortVector_out     (w_availPort[0])
);
			 
seqPortAlloc rank1PortAlloc(
.availPortVector_in      (w_availPort[0]),
.ppv                     (ppv_1),
.allocatedPortVector     (allocPV_1),
.availPortVector_out     (w_availPort[1])
);    


seqPortAlloc rank02ortAlloc(
.availPortVector_in      (w_availPort[1]),
.ppv                     (ppv_2),
.allocatedPortVector     (allocPV_2),
.availPortVector_out     (w_availPort[2])
);

seqPortAlloc rank3PortAlloc(
.availPortVector_in      (w_availPort[2]),
.ppv                     (ppv_3),
.allocatedPortVector     (allocPV_3),
.availPortVector_out     (w_availPort[3])
); 

seqPortAlloc rank4PortAlloc(
.availPortVector_in      (w_availPort[3]),
.ppv                     (ppv_4),
.allocatedPortVector     (allocPV_4),
.availPortVector_out     ()
); 

endmodule
