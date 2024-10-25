// Sequential CLM S-Box implementation, with registers after each combinatorial stage, to "emulate" 
// RAMBAM's software implementation. Registers help with slowing down the computation and increasing the SNR
// to make attacks actually significant and not highly noise-sensitive.

`include "clm_typedefs.svh"
import types::*;


module clm_sbox(inouts, params);
    parameter int d = d;

    sbox_inouts_if.basic inouts;
    params_if.in_use params;

    // Internal stage counters
    sbox_stages_t stage_ctr, stage_ctr_next;

    // 2 wires for each multiple - one without added randomness and one with.
    state_t t1,
            t2_no_random,   t2, t2_saved,
            t3_no_random,   t3, t3_saved,
            t12_no_random,  t12, t12_saved,
            t14_no_random,  t14, t14_saved,
            t15_no_random,  t15, t15_saved,
            t240_no_random, t240, t240_saved,
            t254_no_random, t254, t254_saved;

    // Register enables
    logic reg1_en, reg2_en, reg3_en, reg4_en, reg5_en, reg6_en;
    

    // DATAPATH.
    assign t1 = inouts.in;
    matrix_mul pow2(.out(t2_no_random), .in(t1), .matrix(params.M2));
    mul_add_p mul_add0(.out(t2), .in(t2_no_random), .r(inouts.r[0]), .M(params.MC));
    register_d pipe_stage0(.clk(inouts.clk), .rst(inouts.rst), .en(reg1_en), .in(t2), .out(t2_saved));

    multiplier mult1t2(.out(t3_no_random), .p1(t1), .p2(t2_saved), .PQ(params.PQ));
    mul_add_p mul_add1(.out(t3), .in(t3_no_random), .r(inouts.r[1]), .M(params.MC));
    register_d pipe_stage1(.clk(inouts.clk), .rst(inouts.rst), .en(reg2_en), .in(t3), .out(t3_saved));

    matrix_mul pow4(.out(t12_no_random), .in(t3_saved), .matrix(params.M4));
    mul_add_p mul_add2(.out(t12), .in(t12_no_random), .r(inouts.r[2]), .M(params.MC));
    register_d pipe_stage2(.clk(inouts.clk), .rst(inouts.rst), .en(reg3_en), .in(t12), .out(t12_saved));

    multiplier mult2t12(.out(t14_no_random), .p1(t2_saved), .p2(t12_saved), .PQ(params.PQ));
    mul_add_p mul_add3(.out(t14), .in(t14_no_random), .r(inouts.r[3]), .M(params.MC));
    register_d pipe_stage3(.clk(inouts.clk), .rst(inouts.rst), .en(reg4_en), .in(t14), .out(t14_saved));

    multiplier mult3t12(.out(t15_no_random), .p1(t3_saved), .p2(t12_saved), .PQ(params.PQ));
    mul_add_p mul_add4(.out(t15), .in(t15_no_random), .r(inouts.r[4]), .M(params.MC));
    register_d pipe_stage4(.clk(inouts.clk), .rst(inouts.rst), .en(reg4_en), .in(t15), .out(t15_saved));

    matrix_mul pow16(.out(t240_no_random), .in(t15_saved), .matrix(params.M16));
    mul_add_p mul_add5(.out(t240), .in(t240_no_random), .r(inouts.r[5]), .M(params.MC));
    register_d pipe_stage5(.clk(inouts.clk), .rst(inouts.rst), .en(reg5_en), .in(t240), .out(t240_saved));

    multiplier mult14t240(.out(t254_no_random), .p1(t14_saved), .p2(t240_saved), .PQ(params.PQ));
    mul_add_p mul_add6(.out(t254), .in(t254_no_random), .r(inouts.r[6]), .M(params.MC));
    register_d pipe_stage6(.clk(inouts.clk), .rst(inouts.rst), .en(reg6_en), .in(t254), .out(t254_saved));

    affine_transform raff(.out(inouts.out), .in(t254_saved), .T(params.T), .t(params.t));


    // Assign register enables
    always_comb begin : reg_en
        reg1_en = (stage_ctr == POW2);
        reg2_en = (stage_ctr == MUL1);
        reg3_en = (stage_ctr == POW4);
        reg4_en = (stage_ctr == MUL2);
        reg5_en = (stage_ctr == POW16);
        reg6_en = (stage_ctr == MUL3);        
    end
    


    // Very very simple state machine, being in essence a pipeline
    // without pipelining. This is a lesson from the RAMBAM module
    // which does not have one, and is hard to interface with.
    always_comb begin
        inouts.drdy_o = 1'b0;
        case (stage_ctr)
            POW2: stage_ctr_next = inouts.drdy_i ? MUL1 : POW2;
            MUL1: stage_ctr_next = POW4;
            POW4: stage_ctr_next = MUL2;
            MUL2: stage_ctr_next = POW16;
            POW16: stage_ctr_next = MUL3;
            MUL3: stage_ctr_next = AFF;
            AFF: begin
                inouts.drdy_o = 1'b1;
                stage_ctr_next = POW2;
            end
            default: stage_ctr_next = POW2;
        endcase
    end
    

    // Update state machine
    always_ff @(posedge inouts.clk or posedge inouts.rst) begin
        if (inouts.rst) begin
            stage_ctr <= POW2;
        end else begin
            stage_ctr <= stage_ctr_next;
        end
    end
endmodule

// A simple (m+d)-bit register, with async reset. Used multiple times in the S-Box.
module register_d(out, in, clk, rst, en);
    parameter int d = d;

    input logic clk, rst, en;
    output state_t out;
    input state_t in;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
