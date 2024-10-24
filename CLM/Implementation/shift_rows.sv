`include "clm_typedefs.svh"
import types::*;


module shift_rows(in, out);
    parameter int d = d;

    // First index - row, second index - column
    input state_vec_t in;
    output state_vec_t out;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin
            for (j = 0; j < 4; j++) begin
                assign out[i][j] = in[i][(j+i) % 4];
            end
        end
    endgenerate
endmodule
