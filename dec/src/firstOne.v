`timescale 1ns / 1ps

// highest bit

module firstOne #(parameter WIDTH=1) (dataIn, dataOut);

input    [WIDTH-1:0]      dataIn;
output   [WIDTH-1:0]      dataOut;

wire [WIDTH-1:0] xand_all [0:WIDTH];

assign xand_all [WIDTH] = {WIDTH{1'b1}};

genvar i;
generate 
  for (i=WIDTH-1; i>=0; i=i-1) begin : highest_bit_sel 
    assign dataOut  [i] = dataIn[i] && xand_all[i+1];
	  assign xand_all [i] = ~dataIn[i] && xand_all[i+1];
  end
endgenerate


// Old implementation
//assign dataOut [4] = dataIn[4];
//assign dataOut [3] = ~dataIn[4] && dataIn[3];
//assign dataOut [2] = ~dataIn[4] && ~dataIn[3] && dataIn[2];
//assign dataOut [1] = ~dataIn[4] && ~dataIn[3] && ~dataIn[2] && dataIn[1]; 
//assign dataOut [0] = ~dataIn[4] && ~dataIn[3] && ~dataIn[2] && ~dataIn[1] && dataIn[0];

endmodule 