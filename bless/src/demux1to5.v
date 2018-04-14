`timescale 1ns / 1ps

// demux 1 to 5

module demux1to5 #(parameter WIDTH = 1) (din, sel, out1, out2, out3, out4, out5);

input [WIDTH-1:0] din;
input [2:0] sel;
output [WIDTH-1:0] out1, out2, out3, out4, out5;

/*
   sel   din
   000   out1
   001   out2
   010   out3
   011   out4
   100   out5
*/

wire temp [2:0];

demux1to2 #(WIDTH) demux11(din, sel[0], temp[0], temp[1]);
demux1to2 #(WIDTH) demux21(temp[0], sel[1], temp[2], out3);
demux1to2 #(WIDTH) demux22(temp[1], sel[1], out2, out4);
demux1to2 #(WIDTH) demux31(temp[2], sel[2], out1, out5);

endmodule