// Sequential RAMBAM S-Box implementation, with registers after each combinatorial stage, to "emulate" 
// the software implementation. Registers help with slowing down the computation and increasing the SNR
// to make attacks actually significant and not highly noise-sensitive.
module rambam_sbox_storage(out, clk, rst, plaintext, r);
    // External parameters
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    parameter bit[0:d] Q = `Q;



    output logic [0:7+d] out;
    input logic [0:7+d] plaintext;
    input logic [0:6][0:d-1] r;

    input logic clk, rst;

    // Internal derived parameters; they are read from ../Include/sbox_paramters {d}.svh
    localparam bit[0:8+d] PQ = `PQ;
    localparam bit[0:7+d][0:7+d] W = `W;
    localparam bit[0:7+d] w = `w;
    localparam bit[0:7+d][0:7+d] pow1_mat = `pow1;
    localparam bit[0:7+d][0:7+d] pow2_mat = `pow2;
    localparam bit[0:7+d][0:7+d] pow4_mat = `pow4;


    // 3 wires for each stage - one without added randomness, one with, and one after storage.
    logic [0:7+d] t1,
                  t2_no_random,   t2, t2_saved,
                  t3_no_random,   t3, t3_saved,
                  t12_no_random,  t12, t12_saved,
                  t14_no_random,  t14, t14_saved,
                  t15_no_random,  t15, t15_saved,
                  t240_no_random, t240, t240_saved,
                  t254_no_random, t254, t254_saved;


    // Takes in total 7 cycles to compute the result (8 registers, 2 operations are made in parallel).
    // Each stage contains a calculation, a refresh then storage of the output in an (m+d)-bit register.
    assign t1 = plaintext;
    matrix_mul #(.d(d), .matrix(pow1_mat)) pow2(.out(t2_no_random), .in(t1));
    mul_add_p #(.d(d), .P(P)) mul_add0(.out(t2), .in(t2_no_random), .r(r[0]));
    register_d #(.d(d)) pipe_stage0(.clk(clk), .rst(rst), .in(t2), .out(t2_saved));

    multiplier #(.d(d), .PQ(PQ)) mult1t2(.out(t3_no_random), .p1(t1), .p2(t2_saved));
    mul_add_p #(.d(d), .P(P)) mul_add1(.out(t3), .in(t3_no_random), .r(r[1]));
    register_d #(.d(d)) pipe_stage1(.clk(clk), .rst(rst), .in(t3), .out(t3_saved));

    matrix_mul #(.d(d), .matrix(pow2_mat)) pow4(.out(t12_no_random), .in(t3_saved));
    mul_add_p #(.d(d), .P(P)) mul_add2(.out(t12), .in(t12_no_random), .r(r[2]));
    register_d #(.d(d)) pipe_stage2(.clk(clk), .rst(rst), .in(t12), .out(t12_saved));

    multiplier #(.d(d), .PQ(PQ)) mult2t12(.out(t14_no_random), .p1(t2_saved), .p2(t12_saved));
    mul_add_p #(.d(d), .P(P)) mul_add3(.out(t14), .in(t14_no_random), .r(r[3]));
    register_d #(.d(d)) pipe_stage3(.clk(clk), .rst(rst), .in(t14), .out(t14_saved));

    multiplier #(.d(d), .PQ(PQ)) mult3t12(.out(t15_no_random), .p1(t3_saved), .p2(t12_saved));
    mul_add_p #(.d(d), .P(P)) mul_add4(.out(t15), .in(t15_no_random), .r(r[4]));
    register_d #(.d(d)) pipe_stage4(.clk(clk), .rst(rst), .in(t15), .out(t15_saved));

    matrix_mul #(.d(d), .matrix(pow4_mat)) pow16(.out(t240_no_random), .in(t15_saved));
    mul_add_p #(.d(d), .P(P)) mul_add5(.out(t240), .in(t240_no_random), .r(r[5]));
    register_d #(.d(d)) pipe_stage5(.clk(clk), .rst(rst), .in(t240), .out(t240_saved));

    multiplier #(.d(d), .PQ(PQ)) mult14t240(.out(t254_no_random), .p1(t14_saved), .p2(t240_saved));
    mul_add_p #(.d(d), .P(P)) mul_add6(.out(t254), .in(t254_no_random), .r(r[6]));
    register_d #(.d(d)) pipe_stage6(.clk(clk), .rst(rst), .in(t254), .out(t254_saved));

    affine_transform #(.d(d), .W(W), .w(w)) raff(.out(out), .in(t254_saved));
endmodule
