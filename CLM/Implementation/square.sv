`include "clm_typedefs.svh"
import types::*;

// Raises to the power of 2, then performs modular reduction via refresh
module square(in, out, r, B_ext);
    parameter int d = d;


    input state_t in;
    input red_poly_t r;
    output state_t out;
    input nm_matrix_t B_ext;

    // Result of rasining to the power of 2 without modular reduction 
    logic [0:2*(8+d-1)] pre_mod;

    genvar i, j;
    generate
        for (i = 0; i < 8+d; i++) begin
            assign pre_mod[2*i] = in[i];
            if (i != 7+d) begin
                assign pre_mod[2*i+1] = 1'b0;
            end
        end
    endgenerate

    // Abbreviated form of matrix multiplication
    logic [0:7+d] reduction_term;
    generate
        for (i = 0; i < 8; i++) begin
            logic [0:6+2*d] column;
            for (j = 0; j < 7+2*d; j++) begin
                assign column[j] = B_ext[j][i];
            end
            assign reduction_term[i] = ^({r, pre_mod[8+d:2*(8+d-1)]} & column);
        end
    endgenerate
    assign reduction_term[8:7+d] = r;

    // Calculate the final output using the refresh
    assign out = pre_mod[0:7+d] ^ reduction_term;
endmodule
