`timescale 1ns / 1ps

`include "global.vh"

// parallel port allocator
module portAllocParallel (PVIn, validVector, PVOut);

input [`NUM_CHANNEL*`WIDTH_PV-1:0] PVIn; // there are 5 flits on channels.
input [`NUM_CHANNEL-1:0] validVector;
output [`NUM_CHANNEL*`NUM_PORT-1:0] PVOut;   // there are 6 candidate outport.


wire [`NUM_CHANNEL-1:0] PV [0:`NUM_CHANNEL-1]; // split input PV

genvar i;
generate
   for (i=0; i<`NUM_CHANNEL; i=i+1) begin : bitVectorSplit
      assign PV[i] = PVIn[i*`WIDTH_PV+:`WIDTH_PV];
   end
endgenerate


// allocate non-conflited port
wire [`NUM_CHANNEL-1:0] non_conflict_port [0:`NUM_CHANNEL-1];
wire non_conflit_exist [1:`NUM_CHANNEL-1];

assign non_conflict_port [0] = PV[0];
assign non_conflict_port [1] = PV[1] & (~(PV[0] | PV[2] | PV[3] | PV[4]));
assign non_conflict_port [2] = PV[2] & (~(PV[0] | PV[1] | PV[3] | PV[4]));
assign non_conflict_port [3] = PV[3] & (~(PV[0] | PV[1] | PV[2] | PV[4]));
assign non_conflict_port [4] = PV[4] & (~(PV[0] | PV[1] | PV[2] | PV[3]));

generate
   for (i=1; i<`NUM_CHANNEL; i=i+1) begin : non_conflit_exist_cmp
      assign non_conflit_exist[i] = | non_conflict_port[i];
   end
endgenerate

// Compute available port vector
wire [`NUM_CHANNEL-1:0] APV;
assign APV = ~(non_conflict_port [0] | non_conflict_port[1] | non_conflict_port[2] | non_conflict_port[3] | non_conflict_port[4]);

// The frist, second, and last available port is also known.
wire [3:0] APVFirst, APVSecond, APVLast;
firstOne #(4) firstAvailablePort (APV[3:0], APVFirst);
secondHighestBit secondAvailablePort (APV[3:0], APVSecond);
lastBit LastAvailablePort (APV[3:0], APVLast);


// ----------------------------------------------------------------- //
parameter BYPASS = 6'b100000; 

reg [`NUM_PORT-1:0] FPV [0:4]; // Final allocated Port Vector
always @ * begin
   if (validVector[0]) FPV[0] = {1'b0,non_conflict_port[0]};
   else FPV[0] = 'h0;
   
   if (validVector[1]) begin
      if (non_conflit_exist[1])
         FPV[1] = {1'b0,non_conflict_port[1]};
      else
         FPV[1] = BYPASS;
   end
   else
      FPV[1] = 0;

   if (validVector[2]) begin
      if (non_conflit_exist[2])
         FPV[2] = {1'b0,non_conflict_port[2]};
      else if (non_conflit_exist[1])
         FPV[2] = BYPASS;
      else
         FPV[2] = {2'b0,APVFirst};
   end
   else
      FPV[2] = 0;

   if (validVector[3]) begin
      if (non_conflit_exist[3])
         FPV[3] = {1'b0,non_conflict_port[3]};
      else if (non_conflit_exist[1] && non_conflit_exist[2])
         FPV[3] = BYPASS;
      else if (non_conflit_exist[1] ^ non_conflit_exist[2])
         FPV[3] = {2'b0,APVFirst};
      else
         FPV[3] = {2'b0,APVSecond};
   end
   else
      FPV[3] = 0;
      
   if (validVector[4]) begin
      if (non_conflit_exist[4])
         FPV[4] = {1'b0,non_conflict_port[4]};
      else if (non_conflit_exist [3] && non_conflit_exist[2] && non_conflit_exist[1])  // all previous channels find a non_conflicted port
         FPV[4] = BYPASS;
      else
         FPV[4] = {2'b0,APVLast};
   end
   else
      FPV[4] = 0;
end

// ----------------------------------------------------------------- //

generate
   for (i=0; i<`NUM_CHANNEL; i=i+1) begin : aggregate
      assign PVOut [i*`NUM_PORT+:`NUM_PORT] = FPV[i];
   end
endgenerate

endmodule