// typedefs, interfaces and enums used by the CLM. A good lesson I learned from the messy code that
// RAMBAM is is that typedefs and interfaces for common busses are important, and packages are 
// a very useful thing.

`ifndef CLM_TYPEDEFS_SVH
`define CLM_TYPEDEFS_SVH

`define d 4

import types::*;

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
    typedef logic[0:7][0:7+d] mr_matrix_t;
    typedef logic[0:7+d][0:7] rm_matrix_t;
    typedef logic[0:7+d][0:7+d] rr_matrix_t;

    typedef logic [0:3][0:3][0:7] aes_state_t;
    typedef state_t [0:3][0:3] state_vec_t;
    typedef state_t [0:3] state_word_t;
endpackage

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

    state_word_t in, out;
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


    state_word_t in, out;
    red_poly_t [0:6] r;
    logic clk, rst;
    logic drdy_i, drdy_o;

    // The modport used by the sbox
    modport basic (
        input clk, rst, drdy_i, in, r,
        output out, drdy_o
    );
endinterface

// Interface for all derived parameters (depenedent on P, Q) used throughout the cipher.
// They are identical and denoted in the same way as the ones used in RAMBAM, 
// but are extracted as physical signals and not module parameters.
interface params_if;
    parameter int d = d;

    base_poly_t P;
    red_poly_t Q;
    state_t PQ;

    mm_matrix_t L;
    mm_matrix_t L_inv;
    rr_matrix_t L2;
    dm_matrix_t B;
    mr_matrix_t MC;
    dd_matrix_t T11;
    dm_matrix_t T21;
    rr_matrix_t T;
    state_t t;

    rr_matrix_t M2;
    rr_matrix_t M4;
    rr_matrix_t M16;

    // The modport used by the parameter extraction module dependent on P
    modport ext_p (
        output P, L, L_inv, B, MC,
        // change maybe later
        input T11, T21,
        // Unused
        input Q, PQ, T, t, M2, M4, M16, L2
    );

    // The modport used by the S-Box
    modport in_use (
        // In use
        input P, Q, PQ, L, B, MC, T, t, M2, M4, M16,
        // Unused
        input L_inv, T11, T21, L2
    );
endinterface

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

`endif // CLM_TYPEDEFS_SVH