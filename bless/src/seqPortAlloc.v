`timescale 1ns / 1ps

`include "global.vh"

//   sequential port allocaor

module seqPortAlloc(
  availPortVector_in,
  ppv,
  allocatedPortVector,
  availPortVector_out
);

  input  [`NUM_PORT-1:0] availPortVector_in, ppv;
  output [`NUM_PORT-1:0] allocatedPortVector, availPortVector_out;
  
	wire [`NUM_PORT-1:0] desiredPort, deflectedPort;
	
  firstOne #(`NUM_PORT) port_alloc_desired (ppv & availPortVector_in, desiredPort);	
  firstOne #(`NUM_PORT) port_alloc_deflect (availPortVector_in, deflectedPort);	
	
	assign allocatedPortVector = |desiredPort ? desiredPort : deflectedPort;
  assign availPortVector_out = availPortVector_in & ~allocatedPortVector;
 
endmodule

