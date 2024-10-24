// Fully combinatorial RAMBAM S-Box implementation, with all computations done in a single
// clock cycle. After extracting traces from this, this module was deemed to hard to analyze
// and replaced with the one in rambam_aes_multiple_sbox.sv.
module rambam_sbox(out, plaintext, r);
    // External parameters
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    parameter bit[0:d] Q = `Q;

    output logic [0:7+d] out;
    input logic [0:7+d] plaintext;
    input logic [0:d-1] r[0:6];


    // Internal derived parameters
    localparam bit[0:8+d] PQ = `PQ;
    localparam bit[0:7+d][0:7+d] W = `W;
    localparam bit[0:7+d] w = `w;
    localparam bit[0:7+d][0:7+d] pow1_mat = `pow1;
    localparam bit[0:7+d][0:7+d] pow2_mat = `pow2;
    localparam bit[0:7+d][0:7+d] pow4_mat = `pow4;


    // 2 wires for each multiple - one without added randomness and one with.
    logic [0:7+d] t1,
                  t2_no_random,   t2,
                  t3_no_random,   t3,
                  t12_no_random,  t12,
                  t14_no_random,  t14,
                  t15_no_random,  t15,
                  t240_no_random, t240, 
                  t254_no_random, t254;
endmodule
