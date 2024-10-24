// File for typedefs and register widths used by RAMBAM
`ifndef RAMBAM_DEFS_SVH
`define RAMBAM_DEFS_SVH

`define ROUND_BITS 4
`define ROUNDS 10


`define SBOX_BITS 3
`define SBOX_CYCLES 7


`define STAGE_BITS 4
typedef enum logic[`STAGE_BITS-1:0] {IDLE, PREP_DATA, ADD_ROUND_KEY, SUB_BYTES, SHIFT_ROWS,
                                MIX_COLS, KEY_EXPAND_WAIT, ADD_ROUND_KEY_LAST, MOD_P,
                                PREP_OUTPUT} stages_t;

`define KS_STAGE_BITS 3
typedef enum logic[`KS_STAGE_BITS-1:0] {KS_IDLE, SUB_WORD, XOR, OUT} ks_stages_t;

`endif // RAMBAM_DEFS_SVH
