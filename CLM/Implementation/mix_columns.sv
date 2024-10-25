// The MixColumns stage of the AES cipher.

`include "clm_typedefs.svh"
import types::*;


module mix_columns(out, in, L2);
    parameter int d = d;

    input state_vec_t in;
    output state_vec_t out;
    input rr_matrix_t L2;


    // See matrix_mul.sv for an explanation of the transposition trick.
    state_vec_t in_transposed;
    state_vec_t out_transposed;

    genvar i, j, k;
    generate
        for (i = 0; i < 4; i++) begin : gen_transpose_outer
            for (j = 0; j < 4; j++) begin : gen_transpose_inner
                assign in_transposed[i][j] = in[j][i];
                assign out[i][j] = out_transposed[j][i];
            end
        end
    endgenerate
    generate
        for (k = 0; k < 4; k++) begin
            // One module for each column
            mix_column_single #(.d(d)) mixer(.out(out_transposed[k]),
                                             .in(in_transposed[k]),
                                             .L2(L2));
        end
    endgenerate
endmodule
