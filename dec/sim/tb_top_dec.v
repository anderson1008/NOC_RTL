// testbench for top_dec
`timescale 1ns / 1ps

`include "global.vh"

module tb_top_dec;

reg clk, reset;
reg [`WIDTH_PORT-1:0] dinW, dinE, dinS, dinN;
reg [`WIDTH_PORT-1:0] dinLocal, dinBypass;
reg [`WIDTH_PV-1:0]   PVBypass, PVLocal;

wire [`WIDTH_PORT-1:0] doutW, doutE, doutS, doutN;
wire [`WIDTH_PORT-1:0]  doutLocal, doutBypass;
wire [`WIDTH_PV-1:0] PVBypassOut;


top_dec top_dec_inst (clk, reset, dinW, dinE, dinS, dinN, dinLocal, dinBypass, PVBypass, PVLocal, doutW, doutE, doutS, doutN, doutLocal, doutBypass, PVBypassOut);


initial begin
   clk = 1'b0; reset = 1'b1;  
   dinW = 0;   dinE = 0;   dinS = 0;   dinN = 0;   dinLocal = 0;  dinBypass = 0; PVBypass = 0; PVLocal = 0;
   
   #10;
   reset = 1'b0;
   #10;
   reset = 1'b1;
 
   $monitor ("%t : doutN=%h; doutE=%h; doutS=%h; doutW=%h; doutLocal=%h; doutBypass=%h", $time, doutN, doutE, doutS, doutW, doutLocal, doutBypass);
 
   //Packet format (on the link)
   // [requesterID mshrID pktSize FLITID TIME POS_X POS_Y VLD]
   // [     6        5       3      3     8     3    3     1]  size = 32 
   
   // case 1: bypass conflit with dinW
   dinN = {6'd1, 5'h0, 3'h1, 3'h1, 8'd1, 3'd3, 3'd3, 1'b1, `WIDTH_DATA'hA}; // dst = L
   dinE = {6'd2, 5'h0, 3'h1, 3'h1, 8'd1, 3'd3, 3'd4, 1'b1, `WIDTH_DATA'hB}; // dst = N
   dinS = {6'd3, 5'h0, 3'h1, 3'h1, 8'd1, 3'd3, 3'd2, 1'b1, `WIDTH_DATA'hC}; // dst = S
   dinW = {6'd4, 5'h0, 3'h1, 3'h1, 8'd1, 3'd4, 3'd3, 1'b1, `WIDTH_DATA'hD}; // dst = E 
   #10; 
   dinBypass = {6'd5, 5'h0, 3'h1, 3'h1, 8'd1, 3'd4, 3'd3, 1'b1, `WIDTH_DATA'hE}; // dst = E: deflect to bypass
   PVBypass = 5'b00010; // // dst = E
   dinLocal = {6'd4, 5'h0, 3'h1, 3'h1, 8'd1, 3'd4, 3'd3, 1'b1, `WIDTH_DATA'hF};  // Take West which is the only available ports
   PVLocal = 5'b00010; // reqE -> throttle
   
    #30; // 3-cycles (including one cycle for link traversal

    if ((doutN == dinE) && (doutE == dinW) && (doutS == dinS) && (doutW == dinLocal) && (doutBypass == dinBypass) && (doutLocal == dinN)) begin
      $display ("\n****************************************************** Test 1 Passed ****************************************************\n");
    end
    else begin
      $display ("!!!!!!!!!!!! Error: Test 1 Failed !!!!!!!!!!!!");
      $finish;
    end
    
    // case 2: bypass conflit with dinW
    dinN = {6'd1, 5'h0, 3'h1, 3'h1, 8'd1, 3'd3, 3'd3, 1'b1, `WIDTH_DATA'hA}; // dst = L
    dinE = {6'd2, 5'h0, 3'h1, 3'h1, 8'd2, 3'd3, 3'd2, 1'b1, `WIDTH_DATA'hB}; // dst = S -> select W which is the first available port 
                                                                             // It will be swapped to CH2 after PN
    dinS = {6'd3, 5'h0, 3'h1, 3'h1, 8'd3, 3'd3, 3'd2, 1'b1, `WIDTH_DATA'hC}; // dst = S -> deflect to Bypass
                                                                              // It will be swapped to CH2 after PN
    dinW = {6'd4, 5'h0, 3'h1, 3'h1, 8'd4, 3'd3, 3'd2, 1'b1, `WIDTH_DATA'hD}; // dst = S -> select S which is the second available port
    #10; 
    dinBypass = {6'd5, 5'h0, 3'h1, 3'h1, 8'd1, 3'd4, 3'd3, 1'b1, `WIDTH_DATA'hE}; // dst = E
    PVBypass = 5'b00010; 
    dinLocal = {6'd4, 5'h0, 3'h1, 3'h1, 8'd1, 3'd4, 3'd3, 1'b1, `WIDTH_DATA'hF};  // Take the only available port which is N
    PVLocal = 5'b00010; 
    
     #30; // 3-cycles (including one cycle for link traversal
 
     if ((doutN == dinLocal) && (doutE == dinBypass) && (doutS == dinW) && (doutW == dinE) && (doutBypass == dinS) && (doutLocal == dinN)) begin
       $display ("\n****************************************************** Test 2 Passed ****************************************************\n");
     end
     else begin
       $display ("!!!!!!!!!!!! Error: Test 2 Failed !!!!!!!!!!!!");
       $finish;
     end
    
	#100;
    $finish;
end

always #5 clk = ~clk;
   
endmodule