// Encodes the (random) input r as a codeword. M can be any matrix,
// but in the standard implementation it is the convolution gen matrix.

`include "clm_typedefs.svh"
import types::*;

module mul_P(out, r, M);
    parameter int d = d;

    input red_poly_t r;
    output state_t out;

    input dn_matrix_t M;

    nd_matrix_t M_transposed;

    genvar i, j;
    generate
        for (i = 0; i < 8 + d; i++) begin
            for (j = 0; j < d; j++) begin
                assign M_transposed[i][j] = M[j][i];
            end
        end
    endgenerate
    
    genvar k;
    generate
        for (k = 0; k < 8 + d; k++) begin
            assign out[k] = ^(r & M_transposed[k][0:d-1]);
        end
    endgenerate
endmodule
