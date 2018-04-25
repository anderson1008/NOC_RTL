`ifndef _PERMUTATION_NETWORK
`define _PERMUTATION_NETWORK
`timescale 1ns/1ps
`include "flit.svh"
`include "global.svh"

module permutation_network (
rand_num,
din_0,
din_1,
din_2,
din_3,
dout_0,
dout_1,
dout_2,
dout_3
);

input  [1:0]      rand_num;
input  flit_int_t din_0, din_1, din_2, din_3;
output flit_int_t dout_0, dout_1, dout_2, dout_3;

logic      winner_pn_1_1, winner_pn_1_2, winner_pn_2_1, winner_pn_2_2;
logic      swap_pn_1_1, swap_pn_1_2, swap_pn_2_1, swap_pn_2_2;
flit_int_t pn_intermediate_flit [0:3];
logic [3:0] deflect_1, deflect_2;
flit_int_t modified_deflect_flit_1 [0:3];
flit_int_t modified_deflect_flit_2 [0:3];
genvar i;
flit_int_t din [0:3];
assign din[0] = din_0;
assign din[1] = din_1;
assign din[2] = din_2;
assign din[3] = din_3;


// -------------------   Stage 1  --------------------------

// Arbiter determine the priority
arbiter # (
.WIDTH_LABEL (1)
)arb_pn_st_1_1(
.rand_num     (rand_num[0]),
.label_0      (1'b0),
.label_1      (1'b1),
.vld_0        (din_0.vld),
.vld_1        (din_1.vld),
.gold_0       (din_0.golden),
.gold_1       (din_1.golden),
.silver_0     (din_0.silver),
.silver_1     (din_1.silver),
.flit_id_0    (din_0.flit_id),
.flit_id_1    (din_1.flit_id),
.label_win    (winner_pn_1_1)
);

arbiter # (
.WIDTH_LABEL (1)
)arb_pn_st_1_2(
.rand_num     (rand_num[0]),
.label_0      (1'b0),
.label_1      (1'b1),
.vld_0        (din_2.vld),
.vld_1        (din_3.vld),
.gold_0       (din_2.golden),
.gold_1       (din_3.golden),
.silver_0     (din_2.silver),
.silver_1     (din_3.silver),
.flit_id_0    (din_2.flit_id),
.flit_id_1    (din_3.flit_id),
.label_win    (winner_pn_1_2)
);



// Check PPV and priority to determine if the winner should be swap or sent straight
permutation_steering # (
.MODE   (0)
) permutation_steering_1_1 (
.ppv_0        (din_0.ppv[3:0]),
.ppv_1        (din_1.ppv[3:0]),
.vld_0        (din_0.vld),
.vld_1        (din_1.vld),
.winner       (winner_pn_1_1), 
.deflect_0    (deflect_1 [0]),
.deflect_1    (deflect_1 [1]),
.swap         (swap_pn_1_1)
);

permutation_steering # (
.MODE   (0)
) permutation_steering_1_2 (
.ppv_0        (din_2.ppv[3:0]),
.ppv_1        (din_3.ppv[3:0]),
.vld_0        (din_2.vld),
.vld_1        (din_3.vld),
.winner       (winner_pn_1_2), 
.deflect_0    (deflect_1 [2]),
.deflect_1    (deflect_1 [3]),
.swap         (swap_pn_1_2)
);


generate 
  for (i=0; i<4; i++) begin
    assign modified_deflect_flit_1[i].deflect = deflect_1[i] || din[i].deflect;
    assign modified_deflect_flit_1[i].ppv = din[i].ppv;
    assign modified_deflect_flit_1[i].silver = din[i].silver;
    assign modified_deflect_flit_1[i].golden = din[i].golden;
    assign modified_deflect_flit_1[i].requester_id = din[i].requester_id;
    assign modified_deflect_flit_1[i].mshr_id = din[i].mshr_id;
    assign modified_deflect_flit_1[i].pkt_size = din[i].pkt_size;
    assign modified_deflect_flit_1[i].flit_id = din[i].flit_id;
    assign modified_deflect_flit_1[i].dst_x = din[i].dst_x;
    assign modified_deflect_flit_1[i].dst_y = din[i].dst_y;
    assign modified_deflect_flit_1[i].vld = din[i].vld;
    assign modified_deflect_flit_1[i].payload = din[i].payload;    
  end
endgenerate


// Permuter block execute the swap operation
permuter_block permuter_block_1_1 (
.din_0        (modified_deflect_flit_1[0]), 
.din_1        (modified_deflect_flit_1[1]),
.swap         (swap_pn_1_1),
.dout_0       (pn_intermediate_flit[0]),
.dout_1       (pn_intermediate_flit[1])
);

permuter_block permuter_block_1_2 (
.din_0        (modified_deflect_flit_1[2]), 
.din_1        (modified_deflect_flit_1[3]),
.swap         (swap_pn_1_2),
.dout_0       (pn_intermediate_flit[2]),
.dout_1       (pn_intermediate_flit[3])
);

// -------------------   Stage 2  --------------------------

// Arbiter determine the priority
arbiter # (
.WIDTH_LABEL (1)
)arb_pn_st_2_1(
.rand_num     (rand_num[1]),
.label_0      (1'b0),
.label_1      (1'b1),
.vld_0        (pn_intermediate_flit[0].vld),
.vld_1        (pn_intermediate_flit[2].vld),
.gold_0       (pn_intermediate_flit[0].golden),
.gold_1       (pn_intermediate_flit[2].golden),
.silver_0     (pn_intermediate_flit[0].silver),
.silver_1     (pn_intermediate_flit[2].silver),
.flit_id_0    (pn_intermediate_flit[0].flit_id),
.flit_id_1    (pn_intermediate_flit[2].flit_id),
.label_win    (winner_pn_2_1)
);

arbiter # (
.WIDTH_LABEL (1)
)arb_pn_st_2_2(
.rand_num     (rand_num[1]),
.label_0      (1'b0),
.label_1      (1'b1),
.vld_0        (pn_intermediate_flit[1].vld),
.vld_1        (pn_intermediate_flit[3].vld),
.gold_0       (pn_intermediate_flit[1].golden),
.gold_1       (pn_intermediate_flit[3].golden),
.silver_0     (pn_intermediate_flit[1].silver),
.silver_1     (pn_intermediate_flit[3].silver),
.flit_id_0    (pn_intermediate_flit[1].flit_id),
.flit_id_1    (pn_intermediate_flit[3].flit_id),
.label_win    (winner_pn_2_2)
);

// Check PPV and priority to determine if the winner should be swap or sent straight
permutation_steering # (
.MODE   (1)
) permutation_steering_2_1 (
.ppv_0        (pn_intermediate_flit[0].ppv[3:0]),
.ppv_1        (pn_intermediate_flit[2].ppv[3:0]),
.vld_0        (pn_intermediate_flit[0].vld),
.vld_1        (pn_intermediate_flit[2].vld),
.winner       (winner_pn_2_1), 
.deflect_0    (deflect_2 [0]),
.deflect_1    (deflect_2 [2]),
.swap         (swap_pn_2_1)
);

permutation_steering # (
.MODE   (2)
) permutation_steering_2_2 (
.ppv_0        (pn_intermediate_flit[1].ppv[3:0]),
.ppv_1        (pn_intermediate_flit[3].ppv[3:0]),
.vld_0        (pn_intermediate_flit[1].vld),
.vld_1        (pn_intermediate_flit[3].vld),
.winner       (winner_pn_2_2), 
.deflect_0    (deflect_2 [1]),
.deflect_1    (deflect_2 [3]),
.swap         (swap_pn_2_2)
);


generate 
  for (i=0; i<4; i++) begin
    assign modified_deflect_flit_2[i].deflect = deflect_2[i] || pn_intermediate_flit[i].deflect;
    assign modified_deflect_flit_2[i].ppv = pn_intermediate_flit[i].ppv;
    assign modified_deflect_flit_2[i].silver = pn_intermediate_flit[i].silver;
    assign modified_deflect_flit_2[i].golden = pn_intermediate_flit[i].golden;
    assign modified_deflect_flit_2[i].requester_id = pn_intermediate_flit[i].requester_id;
    assign modified_deflect_flit_2[i].mshr_id = pn_intermediate_flit[i].mshr_id;
    assign modified_deflect_flit_2[i].pkt_size = pn_intermediate_flit[i].pkt_size;
    assign modified_deflect_flit_2[i].flit_id = pn_intermediate_flit[i].flit_id;
    assign modified_deflect_flit_2[i].dst_x = pn_intermediate_flit[i].dst_x;
    assign modified_deflect_flit_2[i].dst_y = pn_intermediate_flit[i].dst_y;
    assign modified_deflect_flit_2[i].vld = pn_intermediate_flit[i].vld;
    assign modified_deflect_flit_2[i].payload = pn_intermediate_flit[i].payload;    
  end
endgenerate


// Permuter block execute the swap operation
permuter_block permuter_block_2_1 (
.din_0        (modified_deflect_flit_2[0]), 
.din_1        (modified_deflect_flit_2[2]),
.swap         (swap_pn_2_1),
.dout_0       (dout_0),
.dout_1       (dout_1)
);

permuter_block permuter_block_2_2 (
.din_0        (modified_deflect_flit_2[1]), 
.din_1        (modified_deflect_flit_2[3]),
.swap         (swap_pn_2_2),
.dout_0       (dout_2),
.dout_1       (dout_3)
);

endmodule

`endif
