module mix_column_single(column_o, column_i);
    parameter int d = 4;
    parameter bit [0:7+d][0:7+d] L_two = '{default:0};


    output logic [3:0][0:7+d] column_o;
    input logic [3:0][0:7+d] column_i;

    // The mixcoluns matrix as defined in AES (for comparisons)
    localparam int mds_matrix[0:3][0:3] = '{
        {2, 3, 1, 1},
        {1, 2, 3, 1},
        {1, 1, 2, 3},
        {3, 1, 1, 2}
    };

    // Partial product matrix PP_ij = MDS_ij * C_i
    logic [3:0][3:0][0:7+d] partial_products;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin : gen_mix_o
            for (j = 0; j < 4; j++) begin : gen_mix_i
                matrix_mul #(.d(d), .matrix(get_mc_matrix(mds_matrix[i][j]))) mixer (
                    .in(column_i[j]),
                    .out(partial_products[i][j])
                );
            end

            // There is no reduction operator that works only on a single dimension,
            // so we need to do it by hand
            assign column_o[i] = partial_products[i][0] ^
                                 partial_products[i][1] ^
                                 partial_products[i][2] ^
                                 partial_products[i][3];
        end
    endgenerate

    // Takes number (i.e. polynomial) from the MDS matrix, returns its representation
    // in the ring as a matrix of multiples
    function static bit[0:7+d][0:7+d] get_mc_matrix(int no);
        if (no == 1) begin
            get_mc_matrix = ident_matrix();
        end else if (no == 2) begin
            get_mc_matrix = L_two;
        end else if (no == 3) begin
            get_mc_matrix = L_two ^ ident_matrix();
        end else begin
            get_mc_matrix = '0;
        end
    endfunction

    function static bit[0:7+d][0:7+d] ident_matrix();
        ident_matrix = '0;
        for (int i = 0; i < 8 + d; i++) begin
            ident_matrix[i][i] = 1;
        end
    endfunction

endmodule

