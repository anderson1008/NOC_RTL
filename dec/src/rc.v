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

input  [`WIDTH_COORDINATE*2-1:0] dst;
output [`WIDTH_PV-1:0]  preferPortVector;
 
rcUC # (CORD_X, CORD_Y) rcUC_inst(
.dst              (dst),
.preferPortVector (preferPortVector)
);
    
endmodule    
