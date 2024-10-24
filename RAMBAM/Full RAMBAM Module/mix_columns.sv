// The MixColumns stage of the AES cipher.
module mix_columns(state_vec_o, state_vec_i);
    parameter int d = `d;
    parameter bit [0:7+d][0:7+d] L_two = `mulL2;

    // First index - row, second index - column
    input logic [3:0][3:0][0:7+d] state_vec_i;
    output logic [3:0][3:0][0:7+d] state_vec_o;


    // See matrix_mul.sv for an explanation of the transposition trick.
    logic [3:0][3:0][0:7+d] state_vec_i_transposed;
    logic [3:0][3:0][0:7+d] state_vec_o_transposed;

    genvar i, j, k;
    generate
        for (i = 0; i < 4; i++) begin : gen_transpose_outer
            for (j = 0; j < 4; j++) begin : gen_transpose_inner
                assign state_vec_i_transposed[i][j] = state_vec_i[j][i];
                assign state_vec_o[i][j] = state_vec_o_transposed[j][i];
            end
        end
    endgenerate
    generate
        for (k = 0; k < 4; k++) begin
            // One module for each column
            mix_column_single #(.d(d), .L_two(L_two)) mixer(.column_o(state_vec_o_transposed[k]),
                                                      .column_i(state_vec_i_transposed[k]));
        end
    endgenerate
endmodule
