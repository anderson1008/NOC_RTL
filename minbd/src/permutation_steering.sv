`ifndef _PERMUTATION_STEERING
`define _PERMUTATION_STEERING
`timescale 1ns/1ps

module permutation_steering # (parameter MODE=0) (
ppv_0,
ppv_1,
vld_0,
vld_1,
winner,
deflect_0,
deflect_1,
swap
);

input [3:0] ppv_0, ppv_1;
input       vld_0, vld_1, winner;
output      deflect_0, deflect_1;
output      swap;

generate 
  if (MODE==0) begin
    assign swap = (winner == 1'b0 && vld_0) ? ((ppv_0[1] || ppv_0[3]) && ~ppv_0[0] && ~ppv_0[2]) : 
		              (winner == 1'b1) ? ((ppv_1[0] || ppv_1[2]) && ~ppv_1[1] && ~ppv_1[3]) : 1'b0;
    assign deflect_0 = (winner == 1'b1) && (ppv_0 == ppv_1) && vld_0 && vld_1;  
    assign deflect_1 = (winner == 1'b0) && (ppv_0 == ppv_1) && vld_0 && vld_1;  
  end
  else if (MODE==1) begin
	  assign swap = (winner == 1'b0) ? (ppv_0[2] && ~ppv_0[3] && ~ppv_0[1] && ~ppv_0[0]) :
		              (winner == 1'b1) ? (ppv_1[0] && ~ppv_1[1] && ~ppv_1[2] && ~ppv_1[3]) : 1'b0;
      assign deflect_0 = ((winner == 1'b1) && (ppv_0 == ppv_1) && vld_0 && vld_1) || ((ppv_0[1] || ppv_0[3]) && vld_0);  
      assign deflect_1 = ((winner == 1'b0) && (ppv_0 == ppv_1) && vld_0 && vld_1) || ((ppv_1[1] || ppv_1[3]) && vld_1);
  end
  else if (MODE==2) begin
	  assign swap = (winner == 1'b0) ? (ppv_0[3] && ~ppv_0[0] && ~ppv_0[1] && ~ppv_0[2]) : 
		              (winner == 1'b1) ? (ppv_1[1] && ~ppv_1[0] && ~ppv_1[2] && ~ppv_1[3]) : 1'b0;
      assign deflect_0 = ((winner == 1'b1) && (ppv_0 == ppv_1) && vld_0 && vld_1) || ((ppv_0[0] || ppv_0[2]) && vld_0);  
      assign deflect_1 = ((winner == 1'b0) && (ppv_0 == ppv_1) && vld_0 && vld_1) || ((ppv_1[0] || ppv_1[2]) && vld_1);
  end
  else begin
	  assign swap = 1'b0;
	  assign deflect_0 = 1'b0;
	  assign deflect_1 = 1'b0;
  end
endgenerate





endmodule
`endif
