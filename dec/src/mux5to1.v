`timescale 1ns / 1ps

// mux 5to1

module mux5to1 #(parameter WIDTH=1) (ina, inb, inc, ind, ine, sel, out);

input  [WIDTH-1:0] ina, inb, inc, ind, ine;
input  [2:0]       sel;
output [WIDTH-1:0] out;

/*
   sel   out
   000   ina
   001   inb
   010   inc
   011   ind
   1xx   ine
*/

wire [WIDTH-1:0] temp1, temp2, temp3;

mux2to1 #(WIDTH) mux11 (ina, inb, sel[0], temp1);
mux2to1 #(WIDTH) mux12 (inc, ind, sel[0], temp2);
mux2to1 #(WIDTH) mux21 (temp1, temp2, sel[1], temp3);
mux2to1 #(WIDTH) mux31 (temp3, ine, sel[2], out);

endmodule