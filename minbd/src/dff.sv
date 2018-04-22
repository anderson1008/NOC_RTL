`timescale 1ns / 1ps

module dff_sync_rst # (parameter WIDTH=1) (
data  , // Data Input
clk    , // Clock Input
reset , // Reset input 
q         // Q output
);
//-----------Input Ports---------------
input [WIDTH-1:0] data;
input clk, reset ; 

//-----------Output Ports---------------
output reg [WIDTH-1:0] q;

//-------------Code Starts Here---------
  always @ ( posedge clk or negedge reset)
if (~reset) begin
  q <= 1'b0;
end  else begin
  q <= data;
end

endmodule //End Of Module dff_async_reset
