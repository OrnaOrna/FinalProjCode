// Multiplies its input by L, an *input* matrix representing the isomorphism, thus
// transferring it to the isomorphic field.
`include "clm_typedefs.svh"
import types::*;

module input_transform(byte_o, byte_i, L);
    input logic [0:7] byte_i;
    output logic [0:7] byte_o;
    input mm_matrix_t L;

    // Copied directly from matrix_mul.sv
    mm_matrix_t matrix_transposed;

    genvar i,j;
    generate
        for (i = 0; i < 8; i++) begin 
            for (j = 0; j < 8; j++) begin 
                assign matrix_transposed[i][j] = L[j][i];
            end
        end
    endgenerate

    genvar k;
    generate
        for (k = 0; k < 8; k++) begin
            assign byte_o[k] = ^(byte_i & matrix_transposed[k][0:7]);
        end
    endgenerate
endmodule
