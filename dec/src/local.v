`timescale 1ns / 1ps

// local eject, kill, inject

`include "global.vh"

module local(allocVector, validVector1, pipeline_reg1_0,pipeline_reg1_1,pipeline_reg1_2,pipeline_reg1_3, dinBypass, dinLocal, PVLocal, XbarPktIn0, XbarPktIn1, XbarPktIn2, XbarPktIn3, XbarPktIn4, XbarPVIn, localOut);

input  [`WIDTH_PV-1:0] validVector1, PVLocal;
input  [`NUM_CHANNEL*`NUM_PORT-1:0] allocVector;
input  [`WIDTH_PORT-1:0] pipeline_reg1_0,pipeline_reg1_1,pipeline_reg1_2,pipeline_reg1_3;
input  [`WIDTH_PORT-1:0] dinBypass, dinLocal;
output [`WIDTH_PORT-1:0] XbarPktIn0, XbarPktIn1, XbarPktIn2, XbarPktIn3, XbarPktIn4, localOut;
output [`NUM_CHANNEL*`WIDTH_PV-1:0] XbarPVIn;

wire [`NUM_CHANNEL-1:0] localVector;
wire [`NUM_PORT-1:0] splitAllocVector [0:`NUM_CHANNEL-1];
wire [`NUM_CHANNEL-1:0] newAllocVector [0:`NUM_CHANNEL-1];
genvar i;
generate 
   for (i=0; i<`NUM_CHANNEL; i=i+1) begin : reformPV
      assign localVector [i] = allocVector[`NUM_PORT*(i+1)-2]; // showing all local-destined flits.
			assign splitAllocVector [i] = allocVector [`NUM_PORT*i +: `NUM_PORT];
      assign newAllocVector[i] = {splitAllocVector[i][`NUM_PORT-1], splitAllocVector[i][3:0]}; // exclude local port
   end
endgenerate

// Local Eject
ejector ejector (localVector, pipeline_reg1_0[`WIDTH_PORT-1:0], pipeline_reg1_1[`WIDTH_PORT-1:0], pipeline_reg1_2[`WIDTH_PORT-1:0], pipeline_reg1_3[`WIDTH_PORT-1:0], dinBypass, localOut);

// Eject kill and select channel to inject local flit.
wire [`WIDTH_PV-1:0] validVector2, injectVector;
assign validVector2 = validVector1 ^ localVector; // unset the valid bit of the local destined flit.
ejectKillNInject ejectKillNInject (validVector2, injectVector);

// Allocate port for Local Flit
// Happen after reforming the PV, in parallel with the eject process.
wire [`NUM_CHANNEL-1:0] APV, APVOut, LPV, ALPV, ALPVOut; // availablePV and localPV
assign APV = ~(newAllocVector[0] | newAllocVector[1] | newAllocVector[2] | newAllocVector[3] | newAllocVector[4]);
firstOne #(`NUM_CHANNEL) firstOneAPV (APV, APVOut);
firstOne #(`NUM_CHANNEL) firstOneLPV (ALPV, ALPVOut);
assign ALPV =  PVLocal & APV;
assign LPV = |ALPV ? ALPVOut : APVOut;

// Inject
assign XbarPktIn0 = injectVector[0] ? dinLocal : pipeline_reg1_0[`WIDTH_PORT-1:0];
assign XbarPktIn1 = injectVector[1] ? dinLocal : pipeline_reg1_1[`WIDTH_PORT-1:0];
assign XbarPktIn2 = injectVector[2] ? dinLocal : pipeline_reg1_2[`WIDTH_PORT-1:0];
assign XbarPktIn3 = injectVector[3] ? dinLocal : pipeline_reg1_3[`WIDTH_PORT-1:0];
assign XbarPktIn4 = injectVector[4] ? dinLocal : dinBypass;

assign XbarPVIn[4:0] = injectVector[0] ? LPV : newAllocVector[0];
assign XbarPVIn[9:5] = injectVector[1] ? LPV : newAllocVector[1];
assign XbarPVIn[14:10] = injectVector[2] ? LPV : newAllocVector[2];
assign XbarPVIn[19:15] = injectVector[3] ? LPV : newAllocVector[3];
assign XbarPVIn[24:20] = injectVector[4] ? LPV : newAllocVector[4];


endmodule