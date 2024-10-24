`include "clm_typedefs.svh"
import types::*;

module affine_transform(in, out, T, t);
    parameter int d = d;

    output state_t out;
    input state_t in, t;
    input rr_matrix_t T;    

    state_t lin_trans;
    matrix_mul linear_transformer (.in(in), .out(lin_trans), .matrix(T));
    assign out = lin_trans ^ t;
endmodule
