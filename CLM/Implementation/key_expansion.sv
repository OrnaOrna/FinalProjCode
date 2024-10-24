`include "clm_typedefs.svh"
import types::*;


module key_expansion(inouts, params);
    parameter int d = d;

    ke_inouts_if.basic inouts;
    params_if.in_use params;


    // Internal state counters
    ks_stages_t stage_ctr, stage_ctr_next;
    logic sbox_drdy;

    // rcon
    logic [0:7] rc, rc_transformed, rc_next;
    state_word_t rcon;

    // Module outputs
    state_word_t rot_word_out, sub_word_out, word_saved;

    // Transposed input and output, since AES works in column-major order
    state_vec_t in_transposed, out_transposed, out_transposed_saved;

    // Register enables
    logic sw_reg_en, rcon_reg_en, out_reg_en, rcon_reg_rst;

    // Loop variables
    genvar i, j;

    // S-Box inouts
    sbox_inouts_if sbox_inouts[4];


    // Transpose inputs and outputs
    generate
        for (i = 0; i < 4; i++) begin : gen_transpose_inout_o
            for (j = 0; j < 4; j++) begin : gen_transpose_inout_i
                assign in_transposed[j][i] = inouts.in[i][j];
                assign inouts.out[i][j] = out_transposed_saved[j][i];
            end
        end
    endgenerate

    // RotWord
    generate 
        for (i = 0; i < 4; i++) begin : gen_rot_word
            assign rot_word_out[i] = in_transposed[3][(i + 1) % 4];
        end
    endgenerate

    // SubWord
    assign sbox_drdy = sbox_inouts[0].drdy_o &&
                       sbox_inouts[1].drdy_o && 
                       sbox_inouts[2].drdy_o && 
                       sbox_inouts[3].drdy_o;
    generate 
        for (i = 0; i < 4; i++) begin : gen_sub_word
            assign sbox_inouts[i].in = rot_word_out[i];
            assign sbox_inouts[i].r = inouts.r;
            assign sbox_inouts[i].clk = inouts.clk;
            assign sbox_inouts[i].rst = inouts.rst;
            assign sbox_inouts[i].drdy_i = (stage_ctr == SUB_WORD);
            assign sub_word_out[i] = sbox_inouts[i].out;

            clm_sbox sbox(.inouts(sbox_inouts[i]), .params(params));
        end
    endgenerate

    // Save output of SubWord
    register_word save_sub_word (
        .clk(inouts.clk),
        .rst(inouts.rst),
        .en(sw_reg_en),
        .in(sub_word_out),
        .out(word_saved)
    );

    // XOR stage
    always_comb begin : xor_stage
        rcon[0] = {rc_transformed, {d{1'b0}}};
        rcon[3:1] = '{default:0};
        out_transposed[0] = in_transposed[0] ^ word_saved ^ rcon;
        out_transposed[1] = in_transposed[1] ^ out_transposed[0];
        out_transposed[2] = in_transposed[2] ^ out_transposed[1];
        out_transposed[3] = in_transposed[3] ^ out_transposed[2];
    end

    // transform rc_i
    input_transform rc_transformer(.byte_o(rc_transformed), .byte_i(rc), .L(params.L));

    // Generate next rc_i
    modular_shift #(.d(0)) rc_shifter (
        .in(rc),
        .out(rc_next),
        .poly(params.P)
    );

    // Save output of XOR
    generate 
        for (i = 0; i < 4; i++) begin : gen_out_regs
            register_word save_out (
                .clk(inouts.clk),
                .rst(inouts.rst),
                .en(out_reg_en),
                .in(out_transposed[i]),
                .out(out_transposed_saved[i])
            );
        end
    endgenerate

    // Assign register enables
    always_comb begin : reg_en
        sw_reg_en = (stage_ctr == SUB_WORD) && (sbox_drdy);
        rcon_reg_en = (stage_ctr == XOR);
        out_reg_en = (stage_ctr == XOR);
        rcon_reg_rst = (stage_ctr == KS_IDLE) && (inouts.first_round);
    end

    // State machine
    always_comb begin : state_machine
        inouts.drdy_o = 1'b0;
        stage_ctr_next = stage_ctr;
        case (stage_ctr)
            KS_IDLE: if (inouts.drdy_i) stage_ctr_next = SUB_WORD;
            SUB_WORD: if (sbox_drdy) stage_ctr_next = XOR;
            XOR: stage_ctr_next = OUT;
            OUT: begin
                stage_ctr_next = KS_IDLE;
                inouts.drdy_o = 1'b1;
            end
            default: begin 
                // Empty
            end
        endcase
    end

    // Update state machine
    always_ff @(posedge inouts.clk, posedge inouts.rst) begin
        if (inouts.rst) begin
            stage_ctr <= KS_IDLE;
            rc <= 8'd128;
        end else begin
            stage_ctr <= stage_ctr_next;
            if (rcon_reg_rst) begin
               rc <= 8'd128;
            end
            if (rcon_reg_en) begin
               rc <= rc_next;
            end
        end
    end
endmodule

module register_word(clk, rst, en, in, out);
    parameter int d = 4;

    input logic clk, rst, en;
    input state_word_t in;
    output state_word_t out;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
