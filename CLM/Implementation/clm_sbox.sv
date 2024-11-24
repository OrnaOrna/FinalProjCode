`include "clm_typedefs.svh"
import types::*;


module clm_sbox(inouts, params);
    parameter int d = d;

    sbox_inouts_if.basic inouts;
    params_if.in_use params;

    // Internal stage counters
    sbox_stages_t stage_ctr, stage_ctr_next;

    // 2 wires multiple - one before storing and one after.
    state_t t1,
            t2, t2_saved,
            t3, t3_saved,
            t12, t12_saved,
            t14, t14_saved,
            t15, t15_saved,
            t240, t240_saved,
            t254, t254_saved;

    // Register enables
    logic reg1_en, reg2_en, reg3_en, reg4_en, reg5_en, reg6_en;
    

    // DATAPATH.
    assign t1 = inouts.in;
    power #(.pow(1)) pow2(.out(t2), .in(t1), .r(inouts.r[0]), .B_ext(params.B_ext));
    register_d pipe_stage0(.clk(inouts.clk), .rst(inouts.rst), .en(reg1_en), .in(t2), .out(t2_saved));

    multiplier mult1t2(.out(t3), .p1(t1), .p2(t2_saved), .r(inouts.r[1]), .B_ext(params.B_ext));
    register_d pipe_stage1(.clk(inouts.clk), .rst(inouts.rst), .en(reg2_en), .in(t3), .out(t3_saved));

    power #(.pow(2)) pow4(.out(t12), .in(t3_saved), .r(inouts.r[2]), .B_ext(params.B_ext));
    register_d pipe_stage2(.clk(inouts.clk), .rst(inouts.rst), .en(reg3_en), .in(t12), .out(t12_saved));

    multiplier mult2t12(.out(t14), .p1(t2_saved), .p2(t12_saved), .r(inouts.r[2]), .B_ext(params.B_ext));
    register_d pipe_stage3(.clk(inouts.clk), .rst(inouts.rst), .en(reg4_en), .in(t14), .out(t14_saved));

    multiplier mult3t12(.out(t15), .p1(t3_saved), .p2(t12_saved), .r(inouts.r[3]), .B_ext(params.B_ext));
    register_d pipe_stage4(.clk(inouts.clk), .rst(inouts.rst), .en(reg4_en), .in(t15), .out(t15_saved));

    power #(.pow(4)) pow16(.out(t240), .in(t15_saved), .r(inouts.r[4]), .B_ext(params.B_ext));
    register_d pipe_stage5(.clk(inouts.clk), .rst(inouts.rst), .en(reg5_en), .in(t240), .out(t240_saved));

    multiplier mult4t240(.out(t254), .p1(t14_saved), .p2(t240_saved), .r(inouts.r[4]), .B_ext(params.B_ext));
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
