`timescale 1ns / 1ps

`include "global.vh"

module tb_top_bless;

reg clk, reset;
reg  [`DATA_WIDTH-1:0] data_in_n, data_in_e, data_in_s, data_in_w, data_in_l;
wire [`DATA_WIDTH-1:0] data_out_n, data_out_e, data_out_s, data_out_w, data_out_l;

top_bless bless_router(
	clk,
	reset,
	data_in_n,
	data_in_e,
	data_in_s,
	data_in_w,
	data_in_l,
	data_out_n,
	data_out_e,
	data_out_s,
	data_out_w,
	data_out_l
);

initial begin
	clk = 1'b0; reset = 1'b1;  
	#10;
	reset = 1'b0;
	data_in_n = 'h0;
	data_in_s = 'h0;
	data_in_w = 'h0;
	data_in_e = 'h0;
	data_in_l = 'h0;
	#10;
	clk = 1'b1; reset = 1'b1;
	#10;

    $monitor ("%t : dout_n=%h; dout_e=%h; dout_s=%h; dout_w=%h; dout_l=%h", $time, data_out_n, data_out_e, data_out_s, data_out_w, data_out_l);

	// Flit format on the link
	// | -----------------  Header  ------------------------------- | ---------------  Payload ---------------------- |
	// timestamp, requesterID, mshrID, pktSize, flitSeqNum, dst, vld                 RESERVED 
	//    8          6            5       3      3           6    1                   256     

	data_in_n = {8'h0,6'd1,5'd5,3'd1,3'd0,3'd3,3'd3,1'b1,256'hDEAD_BEEF_0000_000A}; // local destined
	data_in_e = {8'h1,6'd2,5'd6,3'd1,3'd0,3'd3,3'd2,1'b1,256'hDEAD_BEEF_0000_000B}; // South
	data_in_s = {8'h2,6'd3,5'd7,3'd1,3'd0,3'd3,3'd1,1'b1,256'hDEAD_BEEF_0000_000C}; // FULL_SORT = 1: Deflect to West as data_in_s has higher priority than data_in_l
	                                                                                // FULL_SORT = 0: Deflect to East
	data_in_w = {8'h3,6'd4,5'd8,3'd1,3'd0,3'd0,3'd1,1'b1,256'hDEAD_BEEF_0000_000D}; // FULL_SORT = 1: Deflect to East
	                                                                                // FULL_SORT = 0: West
	data_in_l = {8'h4,6'd5,5'd9,3'd1,3'd0,3'd3,3'd4,1'b1,256'hDEAD_BEEF_0000_000E}; // North   
 
    #30; // 3-cycles (including one cycle for link traversal
	if (`FULL_SORT == 0) begin
        if ((data_out_n == data_in_l) && (data_out_e == data_in_s) && (data_out_s == data_in_e) && (data_out_w == data_in_w) && (data_out_l == data_in_n)) begin
          $display ("\n****************************************************** Test Passed ****************************************************\n");
        end
        else begin
            $display ("!!!!!!!!!!!! Error: Test Failed !!!!!!!!!!!!");
        end
    end
	else begin
      if ((data_out_n == data_in_l) && (data_out_e == data_in_w) && (data_out_s == data_in_e) && (data_out_w == data_in_s) && (data_out_l == data_in_n)) begin
          $display ("\n****************************************************** Test Passed ****************************************************\n");
      end
      else begin
        $display ("!!!!!!!!!!!! Error: Test Failed !!!!!!!!!!!!");
      end
    end	  
	#100;
	$finish;
end

always #5 clk = ~clk;
	 
endmodule
