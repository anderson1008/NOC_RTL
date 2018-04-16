`ifndef _PICK_1OUT4_RAND
`define _PICK_1OUT4_RAND
`timescale 1ns / 1ps

// Get the first 1 to the right from position rand_num

module pick_1out4_rand (data_in, data_out, rand_num);

input    [3:0]            data_in;
input    [1:0]            rand_num;
output   [3:0]            data_out;


// Form a shifted vector (right-shift), the lower-order bit is rotated to high-order
logic [3:0]  tmp [0:2];
logic [3:0]  one_hot_vec;

assign tmp[1] = rand_num [1] ? {data_in[1:0], data_in[3:2]} : data_in;
assign tmp[0] = rand_num [0] ? {tmp[1][0], tmp[1][3:1]} : tmp[1];

first_one #(4) first_one_rand (tmp[0], one_hot_vec);
// Left shift to restore the correct vector
assign tmp[2] = rand_num [1] ? {one_hot_vec[1:0], one_hot_vec[3:2]} : one_hot_vec;
assign data_out = rand_num [0] ? {tmp[2][2:0], tmp[2][3]} : tmp[2];

endmodule

`endif