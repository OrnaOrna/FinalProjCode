// Multiplies by L(2) then performs modular reduction in the CLM style,
// using r as refresh.
`include "clm_typedefs.svh"
import types::*;


module mul_L2(out, in, r, L, B_ext_MC);
    parameter int d = d;

    output state_t out;
    input state_t in;
    input red_poly_t r;
    input mm_matrix_t L;
    input bm_matrix_t B_ext_MC;


        // partial products are extended to length 2m+2d-1, to reach the highest degree available by multiplication
        logic [0:7][0:14+d] partial_products;
        logic [0:6] overflow_sum;
        
        // Calculate the partial products
        genvar i;
        generate
            for (i = 0; i < 8; i++) begin
                if (i != 0) begin
                    assign partial_products[i][0:i-1] = '0;
                end
                assign partial_products[i][i+:8+d] = in & {8+d{L[1][i]}};
                if (i != 7) begin
                    assign partial_products[i][8+i:14+d] = '0;
                end
            end
        endgenerate
    
        // xor over the rows to get the top bits (possible trick with matrix transposition required for compilation)
        generate
            for (i = 0; i < 7; i++) begin
                assign overflow_sum[i] = ^(partial_products[0:7][8+d+i]);
            end
        endgenerate
    
        // Use B_ext_MC as a systematic encoder to get the modular reduction term (again, may need to transpose)
        // concatenation from the LEFT means lower bits, this is where we should add the refresh
        logic [0:7+d] reduction_term;
        generate
            for (i = 0; i < 8; i++) begin
                assign reduction_term[i] = ^({r, overflow_sum} & B_ext_MC[0:6+d][i]);
            end
        endgenerate
        assign reduction_term[8:7+d] = r;
    
        // Calculate the final output using both the refresh and the sum of the partial products
        generate
            for (i = 0; i < 8+d; i++) begin
                assign out[i] = reduction_term[i] ^ (^(partial_products[0:7][i]));
            end
        endgenerate
endmodule