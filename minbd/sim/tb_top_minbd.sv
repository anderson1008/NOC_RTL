
`timescale 1ns / 1ps

`include "global.svh"
`include "flit.svh"
module tb_top_minbd;

logic clk, n_rst;
flit_ext_t din_n, din_e, din_s, din_w, din_l;
flit_ext_t r_din_n, r_din_e, r_din_s, r_din_w, r_din_l;
flit_ext_t dout_n, dout_e, dout_s, dout_w, dout_l_1, dout_l_2;
logic local_inject_gnt;

top_minbd top_minbd (
clk,
n_rst,
din_n,
din_e,
din_s,
din_w,
din_l,
dout_n,
dout_e,
dout_s,
dout_w,
dout_l_1,
dout_l_2,
local_inject_gnt
);


always #5 clk = ~ clk;

initial begin

  $recordsetup("design=top_minbd", "run=1", "version=1");
  $recordvars("depth=5");
  clk = 1'b1; n_rst = 1'b1;  
  #10;
  din_n = '0; din_e = '0; din_s = '0; din_w = '0; din_l = '0;     
  n_rst = 1'b0;
  #10;
  n_rst = 1'b1;
  #5;
  $monitor ("[%t]: dout_n = %h dout_e = %h dout_s = %h, dout_w = %h, dout_l_1 = %h, dout_l_2 = %h", $time, dout_n, dout_e, dout_s, dout_w, dout_l_1, dout_l_2);
  din_n = {1'b0, 6'hA, 5'h0, 3'h1, 3'h0, 3'h3, 3'h3, 1'b1, `WIDTH_DATA'hA}; // dst = L
  din_e = {1'b1, 6'hB, 5'h0, 3'h1, 3'h0, 3'h2, 3'h3, 1'b1, `WIDTH_DATA'hB}; // dst = W
  din_s = {1'b0, 6'hC, 5'h0, 3'h1, 3'h0, 3'h3, 3'h4, 1'b1, `WIDTH_DATA'hC}; // dst = N 
  din_w = {1'b0, 6'hD, 5'h0, 3'h1, 3'h0, 3'h4, 3'h3, 1'b1, `WIDTH_DATA'hD}; // dst = E
  din_l = {1'b0, 6'hE, 5'h0, 3'h1, 3'h0, 3'h3, 3'h2, 1'b1, `WIDTH_DATA'hE}; // dst = S
  r_din_n = din_n; r_din_e = din_e; r_din_s = din_s; r_din_w = din_w; r_din_l = din_l;
  #10;
  din_n = '0; din_e = '0; din_s = '0; din_w = '0; din_l = '0;
  #10;
  if (r_din_n != dout_l_1) begin
    #5;
    $display ("[%t]: ------------------- Test Case 1 FAILED on first stage --------------------", $time);
    $finish;  
  end     
  #10;
  if ((r_din_e != dout_w) && (r_din_s != dout_n) && (r_din_w != dout_e) && (r_din_l != dout_s) && (dout_l_2 != '0)) begin
    #5;
    $display ("[%t]: ------------------- Test Case 1 FAILED on second stage --------------------", $time);
    $finish;
  end
  #10;
  $display ("[%t]: ------------------- Test Case 1 Passed --------------------", $time);
  #1000;
  // TEST Case 2: put the only deflected flit into side buffer  
  din_n = {1'b0, 6'hA, 5'h0, 3'h1, 3'h0, 3'h3, 3'h3, 1'b1, `WIDTH_DATA'hA}; // dst = L
  din_e = {1'b1, 6'hB, 5'h0, 3'h1, 3'h0, 3'h2, 3'h3, 1'b1, `WIDTH_DATA'hB}; // dst = W
  din_s = {1'b0, 6'hC, 5'h0, 3'h1, 3'h0, 3'h2, 3'h4, 1'b1, `WIDTH_DATA'hC}; // dst = W -> put to side buffer -> take W the next cycle 
  din_w = {1'b0, 6'hD, 5'h0, 3'h1, 3'h0, 3'h4, 3'h3, 1'b1, `WIDTH_DATA'hD}; // dst = E
  din_l = {1'b0, 6'hE, 5'h0, 3'h1, 3'h0, 3'h3, 3'h2, 1'b1, `WIDTH_DATA'hE}; // dst = S
  r_din_n = din_n; r_din_e = din_e; r_din_s = din_s; r_din_w = din_w; r_din_l = din_l;
  #10;
  din_n = '0; din_e = '0; din_s = '0; din_w = '0; din_l = '0;
  #10;
  if (r_din_n != dout_l_1) begin
    #5;
    $display ("[%t]: ------------------- Test Case 2 FAILED on first stage --------------------", $time);
    $finish;  
  end         
  #10;
   // Although south port is available for the local injected flit, since din_e takes the west port, local flit is forced to go to north port 
  if ((r_din_e != dout_w) || (r_din_w != dout_s) || (r_din_l != dout_n) || (dout_l_2 != '0)) begin
     #5;
     $display ("[%t]: ------------------- Test Case 2 FAILED on second stage --------------------", $time);
     $finish;  
  end
  #20;
  if (r_din_s != dout_w) begin
    #5;
    $display ("[%t]: ------------------- Test Case 2 FAILED on third stage  --------------------", $time);
    $finish;
  end
  #50;
  $display ("[%t]: ------------------- Test Case 2 Passed --------------------", $time);
  $finish;	
end


endmodule
