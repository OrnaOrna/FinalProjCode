// RAMBAM module as in the paper with 16 S-Boxes running in parallel, and additional 4 S-Boxes used for 
// Key expansion. All params are extracted from ../Include/sbox_parameters {d}.svh
// See the report for general architecture and state machine.
module rambam_aes_multiple_sbox(clk, rst, plaintext, key, random_vect, ciphertext, drdy_i, drdy_o);

    // External parameters
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    parameter bit[0:d] Q = `Q;

    // Derived parameters. 
    localparam bit[0:7+d] PQ = `PQ;
    localparam bit[0:7+d][0:7+d] W = `W;
    localparam bit[0:7+d] w = `w;
    localparam bit[0:7][0:7] L = `L;
    localparam bit[0:7][0:7] LINV = `L_inv;
    localparam bit[0:7+d][0:7+d] L_two = `mulL2;
    localparam bit[0:d-1][0:7] MODP_MAT = `modPmat;
    localparam bit[0:7+d][0:7+d] pow1 = `pow1;
    localparam bit[0:7+d][0:7+d] pow2 = `pow2;
    localparam bit[0:7+d][0:7+d] pow4 = `pow4;


    input logic clk, rst;

    input logic drdy_i;
    output logic drdy_o;

    input logic [0:127] plaintext;
    input logic [0:127] key;
    input logic [0:22][0:d-1] random_vect;
    output logic [0:127] ciphertext;

    // Internal state counters
    logic [`ROUND_BITS - 1: 0] round_ctr, round_ctr_next;
    logic [`SBOX_BITS - 1: 0] sbox_ctr, sbox_ctr_next;
    stages_t stage_ctr, stage_ctr_next;

    // Module outputs
    logic [3:0][3:0][0:7+d] random_input_out, transform_key_stretch, key_expansion_out,
                            add_round_key_out, sbox_out, shift_rows_out,
                            mix_columns_out, add_round_key_last_out;

    logic [3:0][3:0][0:7] transform_input_out, transform_key_out, mod_p_out, inverse_transform_out;

    logic key_expansion_ready, key_expansion_start, key_expansion_restart;

    // Register outputs & mux outputs
    logic [3:0][3:0][0:7+d] state_vec_1, state_vec_2, state_vec_3, state_vec_4,
                            state_vec_5, key_vec, mux_out_1, mux_out_2, mux_out_3;
    logic [3:0][3:0][0:7]   state_vec_6;
    logic [0:6][0:d-1] r_saved;

    // Register enables
    logic reg1_en, reg2_en, reg3_en, reg4_en, reg5_en, reg6_en, reg7_en;

    // Loop variables
    genvar i, j;



    /* DATAPATH (NO REGISTERS) */
    //datapath: begin
        // Input & key transformation
        generate
            for (i = 0; i < 4; i++) begin : gen_i_t_outer
                for (j = 0; j < 4; j++) begin : gen_i_t_inner
                    // The operation inside .byte_i is to extract the correct byte from the input/key
                    input_transform #(.L(L)) input_transformer(.byte_o(transform_input_out[i][j]),
                                                            .byte_i({<<{plaintext[8*i+32*j+:8]}}));
                    mul_add_p #(.d(d), .P(P)) mul_add_input(.out(random_input_out[i][j]),
                                                            .in({transform_input_out[i][j], {d{1'b0}}}),
                                                            .r(random_vect[4*i+j]));

                    input_transform #(.L(L)) key_transformer(.byte_o(transform_key_out[i][j]),
                                                            .byte_i({<<{key[8*i+32*j+:8]}}));
                    assign transform_key_stretch[i][j] = {transform_key_out[i][j], {d{1'b0}}};
               end
            end
        endgenerate

        // Add round key
        add_round_key #(.d(d)) add_round_key(.state_vec_o(add_round_key_out),
                                            .state_vec_i(mux_out_1),
                                            .key(key_vec));

        // S-BOX
        generate
            for (i = 0; i < 4; i++) begin : gen_s_outer
                for (j = 0; j < 4; j++) begin : gen_s_inner
                    rambam_sbox_storage #(.d(d), .P(P), .Q(Q)) 
                        sbox(.clk(clk), .rst(rst), .out(sbox_out[i][j]),
                             .plaintext(state_vec_2[i][j]),
                             .r(shift_randomness(r_saved, 4*i+j)));
                end
            end
        endgenerate

        // Shift rows
        shift_rows #(.d(d)) shift_rows(.state_vec_o(shift_rows_out),
                                    .state_vec_i(state_vec_3));

        // Mix columns
        mix_columns #(.d(d), .L_two(L_two)) mix_columns(.state_vec_o(mix_columns_out),
                                                .state_vec_i(state_vec_4));

        // Last round add round key
        add_round_key #(.d(d)) add_round_key_last(.state_vec_o(add_round_key_last_out),
                                                .state_vec_i(state_vec_4),
                                                .key(key_expansion_out));

        // Reduction modulo P
        generate
            for (i = 0; i < 4; i++) begin : gen_mod_outer
                for (j = 0; j < 4; j++) begin : gen_mod_inner
                    mod_P #(.d(d), .MODP_MAT(MODP_MAT)) mod_p(.out(mod_p_out[i][j]),
                                                .in(state_vec_5[i][j]));
                end
            end
        endgenerate

        // Inverse transformation
        generate
            for (i = 0; i < 4; i++) begin : gen_o_t_outer
                for (j = 0; j < 4; j++) begin : gen_o_t_inner
                    input_transform #(.L(LINV)) output_transformer(.byte_o(inverse_transform_out[i][j]),
                                                                .byte_i(state_vec_6[i][j]));

                end
            end
        endgenerate

        // Key expansion
        key_expansion #(.d(d), .P(P), .Q(Q), .L(L)) key_expansion(.clk(clk), .rst(rst),
                                                           .drdy_i(key_expansion_start),
                                                           .drdy_o(key_expansion_ready),
                                                           .first_round(key_expansion_restart),
                                                           .out(key_expansion_out), .in(key_vec),
                                                           .r(r_saved));
    //end


    /* REGISTERS IN DATAPATH */
    //dpath_regs: begin
        register_state #(.d(d)) reg1(.clk(clk), .rst(rst), .en(reg1_en),
                                    .in(random_input_out), .out(state_vec_1));
        register_state #(.d(d)) reg2(.clk(clk), .rst(rst), .en(reg2_en),
                                    .in(mux_out_2), .out(key_vec));
        register_state #(.d(d)) reg3(.clk(clk), .rst(rst), .en(reg3_en),
                                    .in(add_round_key_out), .out(state_vec_2));
        register_state #(.d(d)) reg4(.clk(clk), .rst(rst), .en(reg4_en),
                                    .in(sbox_out), .out(state_vec_3));
        register_state #(.d(d)) reg5(.clk(clk), .rst(rst), .en(reg5_en),
                                    .in(shift_rows_out), .out(state_vec_4));
        register_state #(.d(d)) reg6(.clk(clk), .rst(rst), .en(reg6_en),
                                    .in(mux_out_3), .out(state_vec_5));
        register_state #(.d(0)) reg7(.clk(clk), .rst(rst), .en(reg7_en),
                                    .in(mod_p_out), .out(state_vec_6));

        // Registers to save r
        always_ff @(posedge clk, posedge rst) begin
            if (rst) begin
                r_saved <= '{default:0};
            end else if (stage_ctr == PREP_DATA) begin
                r_saved <= random_vect[16:22];
            end else if (stage_ctr == MIX_COLS) begin
                r_saved <= shift_randomness(r_saved, 16);
            end
        end
    //end

    // Assign output of module to output of inverse transformation
    generate
        for (i = 0; i < 4; i++) begin : gen_mux_outer
            for (j = 0; j < 4; j++) begin : gen_mux_inner
                assign ciphertext[8*i+32*j+:8] = {<<{inverse_transform_out[i][j]}};
            end
        end
    endgenerate

    // Assign register enables
    always_comb begin : reg_en
        reg1_en = (stage_ctr == PREP_DATA);
        reg2_en = (stage_ctr == PREP_DATA) || key_expansion_ready;
        reg3_en = (stage_ctr == ADD_ROUND_KEY);
        reg4_en = (stage_ctr == SUB_BYTES) && (sbox_ctr == `SBOX_CYCLES);
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
        drdy_o = 1'b0;
        stage_ctr_next = stage_ctr;
        round_ctr_next = round_ctr;
        sbox_ctr_next = '{default:0};
        key_expansion_start = 1'b0;
        key_expansion_restart = 1'b0;
        case(stage_ctr)
            IDLE: begin
                if (drdy_i) begin
                    stage_ctr_next = PREP_DATA;
                    round_ctr_next = `ROUND_BITS'b1;
                    key_expansion_restart = 1'b1;
                end
            end
            PREP_DATA: begin
                stage_ctr_next = ADD_ROUND_KEY;
            end
            ADD_ROUND_KEY: begin
                key_expansion_start = 1'b1;
                stage_ctr_next = SUB_BYTES;
            end
            SUB_BYTES: begin
                if (sbox_ctr == `SBOX_CYCLES) begin
                    stage_ctr_next = SHIFT_ROWS;
                end else begin
                    sbox_ctr_next = sbox_ctr + 1;
                end
            end
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
                drdy_o = 1'b1;
                stage_ctr_next = IDLE;
            end
            default: begin
            end
        endcase
    end

    // Update state machine
    always_ff @(posedge clk, posedge rst) begin : init_and_states
        if (rst) begin
            round_ctr <= `ROUND_BITS'd1;
            stage_ctr <=  IDLE;
            sbox_ctr <= '{default:0};
        end else begin
            round_ctr <= round_ctr_next;
            stage_ctr <= stage_ctr_next;
            sbox_ctr <= sbox_ctr_next;
        end
    end
    
    // A roll of the randomness bus by random_inp (specified at compile-time) positions, used to shift the randomness between S-Box
    // invocations and between rounds.
    function automatic logic [0:6][0:d-1] shift_randomness;
        input logic [0:6][0:d-1] random_inp;
        input integer shamt;

        for (int i = 0; i < 7; i++) begin
            shift_randomness[i][0:d-1] = random_inp[(i + shamt) % 7][0:d-1];
        end
    endfunction
endmodule


// Simple register with async reset and enable for storing a state vector. Used in between stages.
module register_state(clk, rst, en, in, out);
    parameter int d = `d;

    input logic clk, rst, en;
    input logic [3:0][3:0][0:7+d] in;
    output logic [3:0][3:0][0:7+d] out;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
