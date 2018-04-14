// 6to1 mux

/*
   sel   out
   000   ina
   001   inb
   010   inc
   011   ind
   1x0   ine
   1x1   inf
*/

module mux6to1 #(parameter WIDTH = 1) (ina, inb, inc, ind, ine, inf, sel, out);

input [WIDTH-1:0] ina, inb, inc, ind, ine, inf;
input [2:0] sel;
output [WIDTH-1:0] out;

wire temp1, temp2, temp3, temp4;

mux2to1 #(WIDTH) mux11 (ina, inb, sel[0], temp1);
mux2to1 #(WIDTH) mux12 (inc, ind, sel[0], temp2);
mux2to1 #(WIDTH) mux13 (ine, inf, sel[0], temp3);
mux2to1 #(WIDTH) mux21 (temp1, temp2, sel[1], temp4);
mux2to1 #(WIDTH) mux31 (temp4, temp3, sel[2], out);

endmodule