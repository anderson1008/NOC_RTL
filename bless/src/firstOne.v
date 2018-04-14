`timescale 1ns / 1ps

// highest bit

// Get the first 1 from the MSB
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

endmodule 