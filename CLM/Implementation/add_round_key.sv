// The AddRoundKey Stage of the AES cipher.
`include "clm_typedefs.svh"
import types::*;


module add_round_key(in, out, key);
    parameter int d = d;

    input state_vec_t in, key;
    output state_vec_t out;

    assign out = in ^ key;
endmodule