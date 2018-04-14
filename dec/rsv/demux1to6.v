// demux 1 to 6

module demux1to6 #(parameter WIDTH = 1) (din, sel, out1, out2, out3, out4, out5, out6);

input [WIDTH-1:0] din;
input [2:0] sel;
output [WIDTH-1:0] out1, out2, out3, out4, out5, out6;

/*
   sel   din
   000   out1
   001   out2
   010   out3
   011   out4
   100   out5
   101   out6
*/

wire temp [3:0];

demux1to2 #(WIDTH) demux11(din, sel[0], temp[0], temp[1]);
demux1to2 #(WIDTH) demux21(temp[0], sel[0], temp[2], out3);
demux1to2 #(WIDTH) demux22(temp[1], sel[1], temp[3], out4);
demux1to2 #(WIDTH) demux31(temp[2], sel[2], out1, out5);
demux1to2 #(WIDTH) demux32(temp[3], sel[2], out2, out6);

endmodule