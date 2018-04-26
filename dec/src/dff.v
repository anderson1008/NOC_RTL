`timescale 1ns / 1ps

module dff_async_reset # (parameter WIDTH=1) (
data  , // Data Input
clk    , // Clock Input
reset , // Reset input 
en,     // Enable input
q         // Q output
);
//-----------Input Ports---------------
input [WIDTH-1:0] data;
input clk, reset, en ; 

//-----------Output Ports---------------
output reg [WIDTH-1:0] q;

//-------------Code Starts Here---------
always @ ( posedge clk)
if (~reset) begin
  q <= 1'b0;
end  else begin
  if (en) q <= data;
  else q <= q;
end

endmodule //End Of Module dff_async_reset
