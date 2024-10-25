// Reduces its input modulo P, in essence calculating the systematic syndrome.
`include "clm_typedefs.svh"
import types::*;


module mod_P(
    in, out, B
);
    parameter int d = d;

    output logic [0:7] out;
    input state_t in;
    input dm_matrix_t B;

    md_matrix_t B_transposed;
    genvar i,j;

    generate
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < d; j++) begin
                assign B_transposed[i][j] = B[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < 8; i++) begin
            assign out[i] = in[i] ^ (^(B_transposed[i] & in[8:7+d]));
        end
    endgenerate
endmodule
