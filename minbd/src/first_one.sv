`ifndef _FIRST_ONE_SV
`define _FIRST_ONE_SV
`timescale 1ns / 1ps

// highest bit

module first_one #(parameter WIDTH=1) (dataIn, dataOut);

input    [WIDTH-1:0]      dataIn;
output   [WIDTH-1:0]      dataOut;

wire [WIDTH:0] xand_all;

assign xand_all [WIDTH] = 1'b1;


// dataOut[3] = dataIn[3]
// dataOut[2] = ~dataIn[3] && dataIn[2];
// dataOut[1] = ~dataIn[3] && ~dataIn[2] && dataIn[1]


genvar i;
generate 
  for (i=WIDTH; i>0; i=i-1) begin : highest_bit_sel 
    assign dataOut  [i-1] = dataIn[i-1] && xand_all[i];
	  assign xand_all [i-1] = ~dataIn[i-1] && xand_all[i];
  end
endgenerate


endmodule 
`endif