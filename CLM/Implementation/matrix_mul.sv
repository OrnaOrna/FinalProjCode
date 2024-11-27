// Multiplies the input by an (m+d)x(m+d) matrix provided as an input.
`include "clm_typedefs.svh"
import types::*;


module matrix_mul(
    in, out, matrix
);
    parameter int d = d;


    input state_t in;
    output state_t out;
    input nn_matrix_t matrix;

    // AFAIK, SystemVerilog does not allow slicing a column of an array, so we must use a trick where we transpose the matrix, then
    // slice the row of the transposed matrix. After calculating the result, we have to transpose it back.
    nn_matrix_t matrix_transposed;

    genvar i,j;
    generate
        for (i = 0; i < 8 + d; i++) begin 
            for (j = 0; j < 8 + d; j++) begin 
                assign matrix_transposed[i][j] = matrix[j][i];
            end
        end
    endgenerate

    genvar k;
    generate
        for (k = 0; k < 8 + d; k++) begin
            assign out[k] = ^(in & matrix_transposed[k][0:7+d]);
        end
    endgenerate
endmodule
