`include "clm_typedefs.svh"
import types::*;

// CLM multiplier, with reduction modulo "PQ" (using r) done using systematic encoding after computation of the product.
// Combinatorial implementation, may be expensive, may leak.
module multiplier(out, p1, p2, r, B_ext);
    parameter int d = d;
    

    output state_t out;
    input state_t p1, p2;
    input red_poly_t r;
    input mul_m_matrix_t B_ext;

    // partial products are extended to length 2m+2d-1, to reach the highest degree available by multiplication
    logic [0:7+d][0:14+2*d] partial_products;
    logic [0:6+d] overflow_sum;
    
    // Calculate the partial products
    genvar i, j;
    generate
        for (i = 0; i < 8+d; i++) begin
            if (i != 0) begin
                assign partial_products[i][0:i-1] = '0;
            end
            assign partial_products[i][i+:8+d] = p1 & {8+d{p2[i]}};
            if (i != 7+d) begin
                assign partial_products[i][8+d+i:14+2*d] = '0;
            end
        end
    endgenerate

    // xor over the rows to get the top bits (possible trick with matrix transposition required for compilation)
    generate
        for (i = 0; i < 7+d; i++) begin
            logic[0:7+d] column;
            for (j = 0; j < 8+d; j++) begin
                assign column[j] = partial_products[j][8+d+i];
            end
            assign overflow_sum[i] = ^(column);
        end
    endgenerate

    // Use B_ext as a systematic encoder to get the modular reduction term (again, may need to transpose)
    // concatenation from the LEFT means lower bits, this is where we should add the refresh
    state_t reduction_term;
    generate
        for (i = 0; i < 8; i++) begin
            logic [0:6+2*d] column;
            for (j = 0; j < 7+2*d; j++) begin
                assign column[j] = B_ext[j][i];
            end
            assign reduction_term[i] = ^({r, overflow_sum} & column);
        end
    endgenerate
    assign reduction_term[8:7+d] = r;

    // Calculate the final output using both the refresh and the sum of the partial products
    generate
        for (i = 0; i < 8+d; i++) begin
            logic [0:7+d] column;
            for (j = 0; j < 8+d; j++) begin
                assign column[j] = partial_products[j][i];
            end
            assign out[i] = reduction_term[i] ^ (^column);
        end
    endgenerate
endmodule
