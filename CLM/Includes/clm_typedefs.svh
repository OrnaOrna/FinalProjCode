`ifndef CLM_TYPEDEFS_SVH
`define CLM_TYPEDEFS_SVH

`define d 8

// Whether to use 4 or 16 S-Boxes in the Sub-bytes stage
`define CHEAP_SB 0


package types;
    // m = 8, d is a parameter, r = m+d
    parameter int d = `d;

    typedef logic [0:4] p_det_t;
    typedef logic [0:8] base_poly_t;
    typedef logic [0:d-1] red_poly_t;
    typedef logic [0:7+d] state_t;


    typedef logic[0:7][0:7] mm_matrix_t;
    typedef logic[0:d-1][0:d-1] dd_matrix_t;
    typedef logic[0:d-1][0:7] dm_matrix_t;
    typedef logic[0:7][0:d-1] md_matrix_t;
    typedef logic[0:d-1][0:7+d] dn_matrix_t;
    typedef logic[0:7+d][0:d-1] nd_matrix_t;
    typedef logic[0:7][0:7+d] mn_matrix_t;
    typedef logic[0:7+d][0:7] nm_matrix_t;
    typedef logic[0:7+d][0:7+d] nn_matrix_t;
    typedef logic[0:6+2*d][0:7] mul_m_matrix_t;
    typedef logic[0:6+d][0:7] mc_m_matrix_t;


    typedef logic [0:3][0:3][0:7] aes_state_t;
    typedef state_t [0:3][0:3] state_vec_t;
    typedef state_t [0:3] state_word_t;
endpackage

import types::*;

// Inouts for the main CLM module. Does not include anything
// new for CLM, such as the random inputs or P.
interface clm_inouts_if;
    logic clk, rst;
    logic [0:127] plaintext;
    logic [0:127] key;
    logic [0:127] ciphertext;
    logic drdy_i, drdy_o;

    // The modport used by the CLM module.
    modport basic (
        input clk, rst, drdy_i, plaintext, key,
        output ciphertext, drdy_o
    );
endinterface

// Inouts for the key expansion submodule
interface ke_inouts_if;
    parameter int d = d;

    state_vec_t in, out;
    red_poly_t [0:6] r;
    logic clk, rst;
    logic drdy_i, drdy_o, first_round;

    // The modport used by the keyexpansion module.
    modport basic (
        input clk, rst, drdy_i, in, first_round, r,
        output out, drdy_o
    );
endinterface

// Inouts for the sbox submodule
interface sbox_inouts_if;
    parameter int d = d;


    state_t in, out;
    red_poly_t [0:6] r;
    logic clk, rst;
    logic drdy_i, drdy_o;

    // The modport used by the sbox
    modport basic (
        input clk, rst, drdy_i, in, r,
        output out, drdy_o
    );
endinterface

interface sub_bytes_inouts_if;
    logic clk, rst;
    logic active, load_r, drdy_o;
    state_vec_t in, out;
    red_poly_t[0:6] random_vect;

    modport basic (
        input clk, rst, active, load_r, in, random_vect,
        output out, drdy_o
    );
endinterface

// Interface for all derived parameters (depenedent on P, Q) used throughout the cipher.
// They are identical and denoted in the same way as the ones used in RAMBAM, 
// but are extracted as physical signals and not module parameters.
interface params_if;
    parameter int d = d;

    base_poly_t P;

    mm_matrix_t L;
    mm_matrix_t Linv;

    dm_matrix_t B;
    mul_m_matrix_t B_ext;
    mc_m_matrix_t B_ext_MC;

    dn_matrix_t MC;
    mm_matrix_t T11;
    dm_matrix_t T21;
    nn_matrix_t T;
    state_t t;


    modport ext_p (
        output P, L, Linv, B, MC, B_ext, B_ext_MC, T, T11, T21, t
    );

    modport in_use (
        // In use
        input P, L, B, MC, T, t, B_ext, B_ext_MC,
        // Unused
        input Linv, T11, T21
    );
endinterface

function red_poly_t [0:6] shift_randomness;
    input red_poly_t [0:6] random_inp;
    input integer shamt;

    for (int i = 0; i < 7; i++) begin
        shift_randomness[i][0:d-1] = random_inp[(i + shamt) % 7][0:d-1];
    end
endfunction

// Same as in RAMBAM, with an added stage.
`define ROUND_BITS 4
`define ROUNDS 10

`define STAGE_BITS 4
typedef enum logic[`STAGE_BITS-1:0] {IDLE, CALC_PARAMS, PREP_DATA, ADD_ROUND_KEY, SUB_BYTES, SHIFT_ROWS,
                                MIX_COLS, KEY_EXPAND_WAIT, ADD_ROUND_KEY_LAST, MOD_P,
                                PREP_OUTPUT} stages_t;

`define KS_STAGE_BITS 3
typedef enum logic[`KS_STAGE_BITS-1:0] {KS_IDLE, SUB_WORD, XOR, OUT} ks_stages_t;

`define SBOX_BITS 3
typedef enum logic[`SBOX_BITS-1:0] {POW2, MUL1, POW4, MUL2, POW16, MUL3, AFF} sbox_stages_t;

typedef logic[`ROUND_BITS-1:0] round_ctr_t;


`endif
