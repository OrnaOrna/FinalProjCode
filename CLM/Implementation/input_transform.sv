// Multiplies its input by L, an *input* matrix representing the isomorphism, thus
// transferring it to the isomorphic field.
`include "clm_typedefs.svh"
import types::*;

module input_transform(byte_o, byte_i, L);
    input logic [0:7] byte_i;
    output logic [0:7] byte_o;
    input mm_matrix_t L;

    matrix_mul #(.d(0)) linear_transformer (
        .in(byte_i),
        .out(byte_o),
        .matrix(L)
    );
endmodule
