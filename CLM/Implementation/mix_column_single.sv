`include "clm_typedefs.svh"
import types::*;

module mix_column_single(out, in, L2);
    parameter int d = d;

    output state_word_t out;
    input state_word_t in;
    input rr_matrix_t L2;


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
                matrix_mul #(.d(d)) mixer (
                    .in(in[j]),
                    .out(partial_products[i][j]),
                    .matrix(get_mc_matrix(mds_matrix[i][j]))
                );
            end

            // There is no reduction operator that works only on a single dimension,
            // so we need to do it by hand
            assign out[i] = partial_products[i][0] ^
                                 partial_products[i][1] ^
                                 partial_products[i][2] ^
                                 partial_products[i][3];
        end
    endgenerate

    // Takes number (i.e. polynomial) from the MDS matrix, returns its representation
    // in the ring as a matrix of multiples
    function automatic rr_matrix_t get_mc_matrix(input int no);
        if (no == 1) begin
            get_mc_matrix = ident_matrix();
        end else if (no == 2) begin
            get_mc_matrix = L2;
        end else if (no == 3) begin
            get_mc_matrix = L2 ^ ident_matrix();
        end else begin
            get_mc_matrix = '0;
        end
    endfunction

    // Generates an identity matrix of size m+d x m+d
    function automatic rr_matrix_t ident_matrix();
        ident_matrix = '0;
        for (int i = 0; i < 8 + d; i++) begin
            ident_matrix[i][i] = 1;
        end
    endfunction
endmodule

