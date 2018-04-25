`timescale 1ns / 1ps

`include "global.vh"

// Top wrapper of baseline DEC router
module top_dec (clk, reset, dinW, dinE, dinS, dinN, dinLocal, dinBypass, PVBypass, PVLocal, doutW, doutE, doutS, doutN, doutLocal, doutBypass, pv_bypass_out);

input clk, reset;
input [`WIDTH_PORT-1:0] dinW, dinE, dinS, dinN;
input [`WIDTH_PORT-1:0] dinLocal, dinBypass;
input [`WIDTH_PV-1:0]   PVBypass, PVLocal;

output [`WIDTH_PORT-1:0] doutW, doutE, doutS, doutN;
output [`WIDTH_PORT-1:0]  doutLocal, doutBypass;
output [`WIDTH_PV-1:0]  pv_bypass_out;

wire [`WIDTH_PORT-1:0] r_dinW, r_dinE, r_dinS, r_dinN;
wire [`WIDTH_PORT-1:0] r_dinLocal, r_dinBypass;
wire [`WIDTH_PV-1:0] r_PVBypass, r_PVLocal;

// Pipeline register: stage 1
dff_async_reset # (`WIDTH_PORT) pipeline_reg_1_west     (dinW, clk, reset, dinW[`POS_VALID], r_dinW);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_1_east     (dinE, clk, reset, dinE[`POS_VALID], r_dinE); 
dff_async_reset # (`WIDTH_PORT) pipeline_reg_1_south    (dinS, clk, reset, dinS[`POS_VALID], r_dinS);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_1_north    (dinN, clk, reset, dinN[`POS_VALID], r_dinN);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_1_local    (dinLocal, clk, reset, dinLocal[`POS_VALID], r_dinLocal);
dff_async_reset # (`WIDTH_PV)   pipeline_reg_1_pv_local (PVLocal, clk, reset, dinLocal[`POS_VALID], r_PVLocal);



// Route computation
wire [`WIDTH_PV-1:0] prodVector [0:3];

rc #(`CORD_X, `CORD_Y) routeCompNorth ({r_dinN[`POS_X_DST], r_dinN[`POS_Y_DST]}, prodVector[0]);
rc #(`CORD_X, `CORD_Y) routeCompEast ({r_dinE[`POS_X_DST], r_dinE[`POS_Y_DST]}, prodVector[1]);
rc #(`CORD_X, `CORD_Y) routeCompSouth ({r_dinS[`POS_X_DST], r_dinS[`POS_Y_DST]}, prodVector[2]);
rc #(`CORD_X, `CORD_Y) routeCompWest ({r_dinW[`POS_X_DST], r_dinW[`POS_Y_DST]}, prodVector[3]);

wire [`WIDTH_INTERNAL_PV-1:0] pn_in  [0:3];
wire [`WIDTH_INTERNAL_PV-1:0] pn_out [0:3];

assign pn_in[0] = {prodVector[0], r_dinN};
assign pn_in[1] = {prodVector[1], r_dinE};
assign pn_in[2] = {prodVector[2], r_dinS};
assign pn_in[3] = {prodVector[3], r_dinW};

permutationNetwork permutationNetwork (pn_in[0], pn_in[1], pn_in[2], pn_in[3], pn_out[0], pn_out[1], pn_out[2], pn_out[3]);

// Pipeline register: stage 2
wire [`WIDTH_INTERNAL_PV-1:0] pn_out_reg [0:3];

dff_async_reset # (`WIDTH_INTERNAL_PV) pipeline_reg_2_0 (pn_out[0], clk, reset, pn_out[0][`POS_VALID], pn_out_reg[0]);
dff_async_reset # (`WIDTH_INTERNAL_PV) pipeline_reg_2_1 (pn_out[1], clk, reset, pn_out[1][`POS_VALID], pn_out_reg[1]);
dff_async_reset # (`WIDTH_INTERNAL_PV) pipeline_reg_2_2 (pn_out[2], clk, reset, pn_out[2][`POS_VALID], pn_out_reg[2]);
dff_async_reset # (`WIDTH_INTERNAL_PV) pipeline_reg_2_3 (pn_out[3], clk, reset, pn_out[3][`POS_VALID], pn_out_reg[3]);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_2_4  (dinBypass, clk, reset, dinBypass[`POS_VALID], r_dinBypass); // Directly connect with input port
dff_async_reset # (`WIDTH_PV) pipeline_reg_2_5 (PVBypass, clk, reset, dinBypass[`POS_VALID], r_PVBypass); // Directly connect with input port


// ----------------------------------------------------------------- //
//                 Pipeline Stage 2 - PA + XT;
// ----------------------------------------------------------------- //

// Port Allocation
wire [`NUM_CHANNEL*`WIDTH_PV-1:0] reqVector;
wire [`NUM_CHANNEL*`NUM_PORT-1:0] allocVector;
wire [`NUM_CHANNEL-1:0] validVector1;
wire vld_bypass;

assign vld_bypass = (r_dinBypass[`POS_VALID] == 0) ? 1'b0 : 1'b1;

assign reqVector = {r_PVBypass,pn_out_reg[3][`POS_PV],pn_out_reg[2][`POS_PV],pn_out_reg[1][`POS_PV],pn_out_reg[0][`POS_PV]};
assign validVector1 = {vld_bypass, pn_out_reg[3][`POS_VALID],pn_out_reg[2][`POS_VALID],pn_out_reg[1][`POS_VALID],pn_out_reg[0][`POS_VALID]};

portAllocParallel portAllocParallel (reqVector, validVector1, allocVector);

wire [`WIDTH_PORT-1:0] localOut; // ejection to local port
wire [`WIDTH_PORT-1:0] XbarPktIn [0:`NUM_CHANNEL-1];
wire [`NUM_CHANNEL*`WIDTH_PV-1:0] XbarPVIn;

local local (
.allocVector     (allocVector), 
.validVector1    (validVector1), 
.pipeline_reg1_0 (pn_out_reg[0][`WIDTH_PORT-1:0]),
.pipeline_reg1_1 (pn_out_reg[1][`WIDTH_PORT-1:0]),
.pipeline_reg1_2 (pn_out_reg[2][`WIDTH_PORT-1:0]),
.pipeline_reg1_3 (pn_out_reg[3][`WIDTH_PORT-1:0]), 
.dinBypass       (r_dinBypass[`WIDTH_PORT-1:0]), 
.dinLocal        (r_dinLocal[`WIDTH_PORT-1:0]), 
.PVLocal         (r_PVLocal), 
// output
.XbarPktIn0      (XbarPktIn[0]),
.XbarPktIn1      (XbarPktIn[1]), 
.XbarPktIn2      (XbarPktIn[2]), 
.XbarPktIn3      (XbarPktIn[3]), 
.XbarPktIn4      (XbarPktIn[4]), 
.localOut        (localOut), 
.XbarPVIn        (XbarPVIn)     // port allocation result going to Xbar
);


// Switch Traversal
wire [`WIDTH_PORT-1:0] XbarOutW, XbarOutE, XbarOutS, XbarOutN, XbarOutBypass;

xbar5Ports xbar5Ports (XbarPVIn, XbarPktIn[0], XbarPktIn[1], XbarPktIn[2], XbarPktIn[3], XbarPktIn[4], XbarOutN, XbarOutE, XbarOutS, XbarOutW, XbarOutBypass);

// forward PV of bypass flit
reg [`WIDTH_PV-1:0] pv_bypass_o;
always @ * begin
   if (XbarPVIn[4]) pv_bypass_o = XbarPVIn[0*`WIDTH_PV+:`WIDTH_PV];
   else if (XbarPVIn[9]) pv_bypass_o = XbarPVIn[1*`WIDTH_PV+:`WIDTH_PV];
   else if (XbarPVIn[14]) pv_bypass_o = XbarPVIn[2*`WIDTH_PV+:`WIDTH_PV];
   else if (XbarPVIn[19]) pv_bypass_o = XbarPVIn[3*`WIDTH_PV+:`WIDTH_PV];
   else if (XbarPVIn[24]) pv_bypass_o = r_PVBypass;
   else
      pv_bypass_o = 0;
end

// ----------------------------------------------------------------- //
//                 Pipeline Stage 3 - LT;
// ----------------------------------------------------------------- //
wire [`WIDTH_PORT-1:0] r_doutW, r_doutE, r_doutS, r_doutN, r_doutLocal, r_doutBypass;
wire [`WIDTH_PV-1:0]  r_pv_bypass;

dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_west (XbarOutW, clk, reset, XbarOutW[`POS_VALID], r_doutW);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_south (XbarOutS, clk, reset, XbarOutS[`POS_VALID], r_doutS);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_east (XbarOutE, clk, reset, XbarOutE[`POS_VALID], r_doutE);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_north (XbarOutN, clk, reset, XbarOutN[`POS_VALID], r_doutN);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_local (localOut, clk, reset, localOut[`POS_VALID], r_doutLocal);
dff_async_reset # (`WIDTH_PORT) pipeline_reg_3_bypass (XbarOutBypass, clk, reset, XbarOutBypass[`POS_VALID], r_doutBypass);
dff_async_reset # (`WIDTH_PV) pipeline_reg_3_bypass_ppv (pv_bypass_o, clk, reset, XbarOutBypass[`POS_VALID], r_pv_bypass);

assign doutW = r_doutW;
assign doutE = r_doutE;
assign doutS = r_doutS;
assign doutN = r_doutN;
assign doutLocal = r_doutLocal;
assign doutBypass = r_doutBypass; // bypassed flit is only latched at the input.
assign pv_bypass_out = r_pv_bypass;

endmodule