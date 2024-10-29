`include "clm_typedefs.svh"
import types::*;

// CLM module with 16 S-Boxes running in parallel, and additional 4 S-Boxes used for 
// Key expansion.
// See the report for general architecture and state machine.

module clm_aes_multiple_sbox_limited_p(inouts, p_det, Q, random_vect);
    parameter int d = d;
    clm_inouts_if.basic inouts;
    input p_det_t p_det;
    input red_poly_t Q;

    input red_poly_t [0:22] random_vect;

    // Internal state counters
    round_ctr_t round_ctr, round_ctr_next;
    stages_t stage_ctr, stage_ctr_next;

    // Module outputs
    state_vec_t random_input_out, transform_key_stretch, key_expansion_out,
                add_round_key_out, sbox_out, shift_rows_out,
                mix_columns_out, add_round_key_last_out;

    aes_state_t transform_input_out, transform_key_out, mod_p_out, inverse_transform_out;

    ke_inouts_if ke_inouts;
    sbox_inouts_if sbox_inouts[4][4];
    logic [0:3][0:3] sbox_drdys;
    logic sbox_drdy;

    // Register outputs & mux outputs
    state_vec_t state_vec_1, state_vec_2, state_vec_3, state_vec_4,
                            state_vec_5, key_vec, mux_out_1, mux_out_2, mux_out_3;
    aes_state_t state_vec_6;
    red_poly_t [0:22] r_saved;
    // Params calculated in first stage, stored in params_stored for later use
    params_if #(d) params, params_saved;


    // Register enables
    logic reg1_en, reg2_en, reg3_en, reg4_en, reg5_en, reg6_en, reg7_en;

    // Loop variables
    genvar i, j;



    /* DATAPATH (NO REGISTERS) */
    //datapath: begin
        // Parameter Extraction
        p_param_extractor p_extractor (.p_det(p_det), .params(params));

        // Input & key transformation
        generate
            for (i = 0; i < 4; i++) begin : gen_i_t_outer
                for (j = 0; j < 4; j++) begin : gen_i_t_inner
                    input_transform input_transformer(.byte_o(transform_input_out[i][j]),
                                                      .byte_i({<<{inouts.plaintext[8*i+32*j+:8]}}),
                                                      .L(params_saved.L));
                    mul_add_p mul_add_input(.out(random_input_out[i][j]),
                                                     .in({transform_input_out[i][j], {d{1'b0}}}),
                                                     .r(random_vect[4*i+j]),
                                                     .M(params_saved.MC));

                    input_transform key_transformer(.byte_o(transform_key_out[i][j]),
                                                    .byte_i({<<{inouts.key[8*i+32*j+:8]}}),
                                                    .L(params_saved.L));
                    assign transform_key_stretch[i][j] = {transform_key_out[i][j], {d{1'b0}}};
               end
            end
        endgenerate

        // Add round key
        add_round_key add_round_key(.out(add_round_key_out), .in(mux_out_1), .key(key_vec));

        // S-BOX
        assign sbox_drdy = & sbox_drdys;
        generate
            for (i = 0; i < 4; i++) begin : gen_s_outer
                for (j = 0; j < 4; j++) begin : gen_s_inner
                    assign sbox_inouts[i][j].in = state_vec_2[i][j];
                    assign sbox_inouts[i][j].r = shift_randomness(r_saved[16:22], 4*i+j);
                    assign sbox_inouts[i][j].clk = inouts.clk;
                    assign sbox_inouts[i][j].rst = inouts.rst;
                    assign sbox_out[i][j] = sbox_inouts[i][j].out;
                    assign sbox_drdys[i][j] = sbox_inouts[i][j].drdy_o;
                    assign sbox_inouts[i][j].drdy_i = (stage_ctr == SUB_BYTES);
                    clm_sbox sbox (.inouts(sbox_inouts[i][j]), .params(params));
                end
            end
        endgenerate

        // Shift rows
        shift_rows shift_rows(.out(shift_rows_out), .in(state_vec_3));

        // Mix columns
        mix_columns mix_columns(.out(mix_columns_out), .in(state_vec_4), .random_vect(random_vect[0:15]), .L(params_saved.L), .B_ext_MC(params_saved.B_ext_MC), .MC(params_saved.MC));

        // Last round add round key
        add_round_key #(.d(d)) add_round_key_last(.in(add_round_key_last_out),
                                                  .out(state_vec_4),
                                                .key(key_expansion_out));

        // Reduction modulo P
        generate
            for (i = 0; i < 4; i++) begin : gen_mod_outer
                for (j = 0; j < 4; j++) begin : gen_mod_inner
                    mod_P mod_p(.out(mod_p_out[i][j]), .in(state_vec_5[i][j]), .B(params_saved.B));
                end
            end
        endgenerate

        // Inverse transformation
        generate
            for (i = 0; i < 4; i++) begin : gen_o_t_outer
                for (j = 0; j < 4; j++) begin : gen_o_t_inner
                    input_transform output_transformer(.byte_o(inverse_transform_out[i][j]),
                                                       .byte_i(state_vec_6[i][j]),
                                                       .L(params_saved.L_inv));

                end
            end
        endgenerate

        // Key expansion
        assign ke_inouts.in = key_vec;
        assign ke_inouts.r = r_saved[16:22];
        assign ke_inouts.clk = inouts.clk;
        assign ke_inouts.rst = inouts.rst;
        key_expansion #(.d(d)) key_expansion(.inouts(ke_inouts), .params(params_saved));
    //end


    /* REGISTERS IN DATAPATH */
    //dpath_regs: begin
        register_state #(.d(d)) reg1(.clk(inouts.clk), .rst(inouts.rst), .en(reg1_en),
                                    .in(random_input_out), .out(state_vec_1));
        register_state #(.d(d)) reg2(.clk(inouts.clk), .rst(inouts.rst), .en(reg2_en),
                                    .in(mux_out_2), .out(key_vec));
        register_state #(.d(d)) reg3(.clk(inouts.clk), .rst(inouts.rst), .en(reg3_en),
                                    .in(add_round_key_out), .out(state_vec_2));
        register_state #(.d(d)) reg4(.clk(inouts.clk), .rst(inouts.rst), .en(reg4_en),
                                    .in(sbox_out), .out(state_vec_3));
        register_state #(.d(d)) reg5(.clk(inouts.clk), .rst(inouts.rst), .en(reg5_en),
                                    .in(shift_rows_out), .out(state_vec_4));
        register_state #(.d(d)) reg6(.clk(inouts.clk), .rst(inouts.rst), .en(reg6_en),
                                    .in(mux_out_3), .out(state_vec_5));
        register_state #(.d(0)) reg7(.clk(inouts.clk), .rst(inouts.rst), .en(reg7_en),
                                    .in(mod_p_out), .out(state_vec_6));

        // Registers to save r
        always_ff @(posedge inouts.clk, posedge inouts.rst) begin
            if (inouts.rst) begin
                r_saved <= '{default:0};
            end else if (stage_ctr == CALC_PARAMS) begin
                params_saved <= params;
            end else if (stage_ctr == PREP_DATA) begin
                r_saved <= random_vect;
            end else if (stage_ctr == MIX_COLS) begin
                r_saved[16:22] <= shift_randomness(r_saved[16:22], 16);
            end
        end
    //end

    // Assign output of module to output of inverse transformation
    generate
        for (i = 0; i < 4; i++) begin : gen_mux_outer
            for (j = 0; j < 4; j++) begin : gen_mux_inner
                assign inouts.ciphertext[8*i+32*j+:8] = {<<{inverse_transform_out[i][j]}};
            end
        end
    endgenerate

    // Assign register enables
    always_comb begin : reg_en
        reg1_en = (stage_ctr == PREP_DATA);
        reg2_en = (stage_ctr == PREP_DATA) || ke_inouts.drdy_o;
        reg3_en = (stage_ctr == ADD_ROUND_KEY);
        reg4_en = (stage_ctr == SUB_BYTES) && (sbox_drdy);
        reg5_en = (stage_ctr == SHIFT_ROWS);
        reg6_en = (stage_ctr == MIX_COLS) || (stage_ctr == ADD_ROUND_KEY_LAST);
        reg7_en = (stage_ctr == MOD_P);
    end

    // Muxes
    always_comb begin : muxes
        mux_out_1 = (round_ctr == `ROUND_BITS'd1) ? state_vec_1 : state_vec_5;
        mux_out_2 = (stage_ctr == PREP_DATA) ? transform_key_stretch : key_expansion_out;
        mux_out_3 = (round_ctr == `ROUND_BITS'd`ROUNDS) ? add_round_key_last_out : mix_columns_out;
    end

    // State machine
    always_comb begin : state_machine
        inouts.drdy_o = 1'b0;
        stage_ctr_next = stage_ctr;
        round_ctr_next = round_ctr;
        ke_inouts.drdy_i = 1'b0;
        ke_inouts.first_round = 1'b0;
        case(stage_ctr)
            IDLE: begin
                if (inouts.drdy_i) begin
                    stage_ctr_next = CALC_PARAMS;
                    round_ctr_next = `ROUND_BITS'b1;
                    ke_inouts.first_round = 1'b1;
                end
            end
            CALC_PARAMS: stage_ctr_next = PREP_DATA;
            PREP_DATA: stage_ctr_next = ADD_ROUND_KEY;
            ADD_ROUND_KEY: begin
                ke_inouts.drdy_i = 1'b1;
                stage_ctr_next = SUB_BYTES;
            end
            SUB_BYTES: if (sbox_drdy) stage_ctr_next = SHIFT_ROWS;
            SHIFT_ROWS: begin
                if (round_ctr == `ROUND_BITS'd`ROUNDS) begin
                    stage_ctr_next = ADD_ROUND_KEY_LAST;
                end else begin
                    stage_ctr_next = MIX_COLS;
                end
            end
            MIX_COLS: begin
                stage_ctr_next = ADD_ROUND_KEY;
                round_ctr_next = round_ctr + 1;
            end
            ADD_ROUND_KEY_LAST: begin
                stage_ctr_next = MOD_P;
            end
            MOD_P: begin
                stage_ctr_next = PREP_OUTPUT;
            end
            PREP_OUTPUT: begin
                inouts.drdy_o = 1'b1;
                stage_ctr_next = IDLE;
            end
            default: begin
                // Empty
            end
        endcase
    end

    // Update state machine
    always_ff @(posedge inouts.clk, posedge inouts.rst) begin : init_and_states
        if (inouts.rst) begin
            round_ctr <= `ROUND_BITS'd1;
            stage_ctr <=  IDLE;
        end else begin
            round_ctr <= round_ctr_next;
            stage_ctr <= stage_ctr_next;
        end
    end

    function automatic red_poly_t [0:6] shift_randomness;
        input red_poly_t [0:6] random_inp;
        input integer shamt;

        for (int i = 0; i < 7; i++) begin
            shift_randomness[i][0:d-1] = random_inp[(i + shamt) % 7][0:d-1];
        end
    endfunction
endmodule

// Simple register w/ async reset and enable for a state vector
module register_state(clk, rst, en, in, out);
    parameter int d = 4;

    input logic clk, rst, en;
    input state_vec_t in;
    output state_vec_t out;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
