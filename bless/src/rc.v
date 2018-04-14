`timescale 1ns / 1ps

`include "global.vh"

module rc # (
  parameter CORD_X = 1,
	parameter CORD_Y = 1
)
(
  dst,
  preferPortVector
);

input  [`DST_WIDTH-1:0] dst;
output [`NUM_PORT-1:0]  preferPortVector;
 
rcUC # (CORD_X, CORD_Y) rcUC_inst(
.dst              (dst),
.preferPortVector (preferPortVector)
);
    
endmodule    
