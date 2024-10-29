// Mixes a single column, refreshing the randomness for each element
// in the CLM style.

`include "clm_typedefs.svh"
import types::*;


module mix_column_single(out, in, random_vect, L, B_ext_MC, MC);
    parameter int d = d;

    output state_word_t out;
    input state_word_t in;
    input red_poly_t[0:15] random_vect;
    input mm_matrix_t L;
    input bm_matrix_t B_ext_MC;
    input mr_matrix_t MC;


    // The mixcoluns matrix as defined in AES (for comparison and extraction)
    localparam int mds_matrix[0:3][0:3] = '{
        {2, 3, 1, 1},
        {1, 2, 3, 1},
        {1, 1, 2, 3},
        {3, 1, 1, 2}
    };

    // Partial product matrix PP_ij = MDS_ij * C_i
    state_vec_t partial_products;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin : gen_mix_o
            for (j = 0; j < 4; j++) begin : gen_mix_i
                if (mds_matrix[i][j] == 1) begin
                    mul_add_p(.out(partial_products[i][j]),
                            .in(in[j]), .r(random_vect[4*i+j]),
                            .M(MC));
                end else if (mds_matrix[i][j] == 2) begin
                    mul_L2 mul_L2_inst(.out(partial_products[i][j]),
                                       .in(in[j]), .r(random_vect[4*i+j]),
                                       .L(L), .B_ext_MC(B_ext_MC));
                end else if (mds_matrix[i][j] == 3) begin
                    state_t temp;
                    mul_L2 mul_L2_inst(.out(temp),
                                       .in(in[j]), .r(random_vect[4*i+j]),
                                       .L(L), .B_ext_MC(B_ext_MC));
                    assign partial_products[i][j] = temp ^ in[j];
                end else begin
                    assign partial_products[i][j] = '0;
                end
            end

            // There is no reduction operator that works only on a single dimension,
            // so we need to do it by hand
            assign out[i] = partial_products[i][0] ^
                                 partial_products[i][1] ^
                                 partial_products[i][2] ^
                                 partial_products[i][3];
        end
    endgenerate
endmodule

