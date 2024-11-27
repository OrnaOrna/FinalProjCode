// Takes an input and adds to it a random codeword, with the randomness provided as an input.
// Any implementation of mul_P can be used (both the systematic and the convolution encoder).
`include "clm_typedefs.svh"
import types::*;


module mul_add_p(out, in, r, M);
    parameter int d = d;
    

    output state_t out;
    input state_t in;
    input red_poly_t r;
    input dn_matrix_t M;


    state_t rP;
    mul_P mul_P_inst(.out(rP), .r(r), .M(M));
    assign out = in ^ rP;
endmodule
