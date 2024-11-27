// MixCols in the CLM style. The randomness is the same for all columns -- this may
// cause a vulnerability.
`include "clm_typedefs.svh"
import types::*;


module mix_columns(out, in, random_vect, L, B_ext_MC, MC);
    parameter int d = d;

    // First index - row, second index - column
    input state_vec_t in;
    input red_poly_t[0:15] random_vect;
    output state_vec_t out;
    input mm_matrix_t L;
    input mc_m_matrix_t B_ext_MC;
    input mn_matrix_t MC;


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
            mix_column_single mixer(.out(out_transposed[k]),
                                    .in(in_transposed[k]),
                                    .random_vect(random_vect),
                                    .L(L), .B_ext_MC(B_ext_MC),
                                    .MC(MC));
        end
    endgenerate
endmodule
