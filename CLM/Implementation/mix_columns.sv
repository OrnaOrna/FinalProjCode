`include "clm_typedefs.svh"
import types::*;


module mix_columns(out, in, L2);
    parameter int d = d;

    // First index - row, second index - column
    input state_vec_t in;
    output state_vec_t out;
    input rr_matrix_t L2;


    // We need to transpose the input, then apply a mix-columns opearation on
    // each column, and then transpose the result back (because of the way indexing works in SystemVerilog)
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
            mix_column_single #(.d(d)) mixer(.out(out_transposed[k]),
                                             .in(in_transposed[k]),
                                             .L2(L2));
        end
    endgenerate
endmodule
