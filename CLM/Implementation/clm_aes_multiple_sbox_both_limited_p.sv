`include "clm_typedefs.svh"
import types::*;

// CLM module with either 4 or 16 S-Boxes running in parallel, and additional 4 S-Boxes used for 
// Key expansion.
// See the report for general architecture and state machine.

module clm_aes_multiple_sbox_limited_p(inouts, p_det, random_vect);
    parameter int d = d;
    clm_inouts_if.basic inouts;
    input p_det_t p_det;

    input red_poly_t [0:22] random_vect;

    // Internal state counters
    round_ctr_t round_ctr, round_ctr_next;
    stages_t stage_ctr, stage_ctr_next;

    // Module outputs
    state_vec_t random_input_out, transform_key_stretch,
                add_round_key_out, shift_rows_out,
                mix_columns_out, add_round_key_last_out;

    aes_state_t transform_input_out, transform_key_out, mod_p_out, inverse_transform_out;

    ke_inouts_if ke_inouts();
    sub_bytes_inouts_if sub_bytes_inouts();

    logic sbox_drdy;

    // Register outputs & mux outputs
    state_vec_t state_vec_1, state_vec_2, state_vec_3, state_vec_4,
                            state_vec_5, key_vec, mux_out_1, mux_out_2, mux_out_3;
    aes_state_t state_vec_6;
    red_poly_t [0:22] r_saved;
    // Params calculated in first stage, stored in params_stored for later use
    params_if params(), params_saved();


    // Register enables
    logic reg1_en, reg2_en, reg3_en, reg5_en, reg6_en, reg7_en;

    // Loop variables
    genvar i, j;



    /* DATAPATH (NO REGISTERS) */
    //datapath: begin
        // Parameter Extraction
        p_param_extractor p_extractor (.p_det(p_det), .params(params.ext_p));

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


        assign sub_bytes_inouts.in = state_vec_2;
        assign sub_bytes_inouts.random_vect = random_vect[16:22];
        assign sub_bytes_inouts.clk = inouts.clk;
        assign sub_bytes_inouts.rst = inouts.rst;
        assign sub_bytes_inouts.active = (stage_ctr == SUB_BYTES);
        assign state_vec_3 = sub_bytes_inouts.out;
        assign sbox_drdy = sub_bytes_inouts.drdy_o;
        assign sub_bytes_inouts.load_r = (stage_ctr == PREP_DATA);
        generate
            if (`CHEAP_SB) begin
                four_sbox sub_bytes(sub_bytes_inouts.basic, params_saved.in_use);
            end else begin
                sixteen_sbox sub_bytes(sub_bytes_inouts.basic, params_saved.in_use);
            end
        endgenerate
        

        // Shift rows
        shift_rows shift_rows(.out(shift_rows_out), .in(state_vec_3));

        // Mix columns
        mix_columns mix_columns(.out(mix_columns_out), .in(state_vec_4), .random_vect(r_saved[0:15]), .L(params_saved.L), .B_ext_MC(params_saved.B_ext_MC), .MC(params_saved.MC));

        // Last round add round key
        add_round_key add_round_key_last(.out(add_round_key_last_out), .in(state_vec_4),
                                         .key(ke_inouts.out));

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
                                                       .L(params_saved.Linv));
                    
                end
            end
        endgenerate

        // Key expansion
        assign ke_inouts.in = key_vec;
        assign ke_inouts.r = r_saved[16:22];
        assign ke_inouts.clk = inouts.clk;
        assign ke_inouts.rst = inouts.rst;
        key_expansion key_expansion(.inouts(ke_inouts.basic), .params(params_saved.in_use));
    //end


    /* REGISTERS IN DATAPATH */
    //dpath_regs: begin
        register_state #(.d(d)) reg1(.clk(inouts.clk), .rst(inouts.rst), .en(reg1_en),
                                    .in(random_input_out), .out(state_vec_1));
        register_state #(.d(d)) reg2(.clk(inouts.clk), .rst(inouts.rst), .en(reg2_en),
                                    .in(mux_out_2), .out(key_vec));
        register_state #(.d(d)) reg3(.clk(inouts.clk), .rst(inouts.rst), .en(reg3_en),
                                    .in(add_round_key_out), .out(state_vec_2));
        register_state #(.d(d)) reg5(.clk(inouts.clk), .rst(inouts.rst), .en(reg5_en),
                                    .in(shift_rows_out), .out(state_vec_4));
        register_state #(.d(d)) reg6(.clk(inouts.clk), .rst(inouts.rst), .en(reg6_en),
                                    .in(mux_out_3), .out(state_vec_5));
        register_aes_state reg7(.clk(inouts.clk), .rst(inouts.rst), .en(reg7_en),
                                    .in(mod_p_out), .out(state_vec_6));

        // Registers to save r
        always_ff @(posedge inouts.clk, posedge inouts.rst) begin
            if (inouts.rst) begin
                r_saved <= '{default:0};
                params_saved.P <= '0;
                params_saved.L <= '0;
                params_saved.Linv <= '0;
                params_saved.B <= '0;
                params_saved.B_ext <= '0;
                params_saved.B_ext_MC <= '0;
                params_saved.MC <= '0;
                params_saved.T11 <= '0;
                params_saved.T21 <= '0;
                params_saved.T <= '0;
                params_saved.t <= '0;
            end else if (stage_ctr == CALC_PARAMS) begin
                params_saved.P <= params.P;
                params_saved.L <= params.L;
                params_saved.Linv <= params.Linv;
                params_saved.B <= params.B;
                params_saved.B_ext <= params.B_ext;
                params_saved.B_ext_MC <= params.B_ext_MC;
                params_saved.MC <= params.MC;
                params_saved.T11 <= params.T11;
                params_saved.T21 <= params.T21;
                params_saved.T <= params.T;
                params_saved.t <= params.t;
            end else if (stage_ctr == PREP_DATA) begin
                r_saved <= random_vect;
            end else if (stage_ctr == MIX_COLS) begin
                r_saved[16:22] <= shift_randomness(r_saved[16:22], 4);
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
        reg5_en = (stage_ctr == SHIFT_ROWS);
        reg6_en = (stage_ctr == MIX_COLS) || (stage_ctr == ADD_ROUND_KEY_LAST);
        reg7_en = (stage_ctr == MOD_P);
    end

    // Muxes
    always_comb begin : muxes
        mux_out_1 = (round_ctr == `ROUND_BITS'd1) ? state_vec_1 : state_vec_5;
        mux_out_2 = (stage_ctr == PREP_DATA) ? transform_key_stretch : ke_inouts.out;
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

// Simple register w/ async reset and enable for a state vector
module register_aes_state(clk, rst, en, in, out);
    input logic clk, rst, en;
    input aes_state_t in;
    output aes_state_t out;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
