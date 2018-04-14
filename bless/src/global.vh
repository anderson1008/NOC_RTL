`timescale 1ns / 1ps

// Change me to select the DUT


// ---------------------  Gloabl Parameter Define Start Here  -------------------------- //


// 1. In paper, dpv (desired port vector) is equivalent to ppv (productive port vector)
// 2. Limitation:
//    The implemetation assume each router has 4 output port. Thus it does not consider 
//    the router on the edge
// 3. Port index
//    0: North
//    1: East
//    2: South
//    3: West
//    4: Local 


`define     NETWORK_SIZE    64
`define     NUM_PORT        5
`define     LOG_NUM_PORT    3
`define     CORD_X          3
`define     CORD_Y          3
`define     PC_INDEX_WIDTH  3
`define     NULL_PC         5
`define     X_COORD         5:3
`define     Y_COORD         2:0

// Flit format on the link
// | -----------------  Header  ------------------------------- | ---------------  Payload ---------------------- |
// timestamp, requesterID, mshrID, pktSize, flitSeqNum, dst, vld                 RESERVED 
//    8          6            5       3      3           6    1                   256     

`define     DATA_WIDTH      `HEADER_WIDTH+`PAYLOAD_WIDTH
`define     IR_DATA_WIDTH   `DATA_WIDTH    // internal data width
`define     HEADER_WIDTH    32
`define     PAYLOAD_WIDTH   256

`define     VLD_POS         `PAYLOAD_WIDTH
`define     VLD_END         `PAYLOAD_WIDTH+1
`define     DST_POS         `VLD_END+:6
`define     DST_END         `VLD_END+6
`define     FLIT_NUM_POS    `DST_END+:3
`define     FLIT_NUM_END    `DST_END+3
`define     PKT_SIZE_POS    `FLIT_NUM_END+:3
`define     PKT_SIZE_END    `FLIT_NUM_END+3
`define     MSHR_POS        `PKT_SIZE_END+:6
`define     MSHR_END        `PKT_SIZE_END+6
`define     REQ_ID_POS      `MSHR_END+:5
`define     REQ_ID_END      `MSHR_END+5 
`define     TIME_POS        `REQ_ID_END+:8

`define     DST_Y_COORD     `VLD_END+:3
`define     DST_X_COORD     (`VLD_END+3)+:3
`define     DST_WIDTH       6
`define     NUM_FLIT_WDITH  3
`define     TIME_WIDTH      8           // width of the time stamp
`define     MAX_TIME        255


// Component Config
// Permutation Network
`define     PERM_WIDTH      `DATA_WIDTH + `NUM_PORT // data width + PPV_WITDH
`define     PPV_POS         `DATA_WIDTH+:5
`define     DATA_POS        0+:`DATA_WIDTH
`define     FULL_SORT       1


