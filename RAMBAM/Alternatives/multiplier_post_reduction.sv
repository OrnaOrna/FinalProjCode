`include "clm_typedefs.svh"
import types::*;

// CLM-style multiplier, with reduction modulo "PQ" (using r) done using systematic encoding after computation of the product.
// Combinatorial implementation, may be expensive, may leak.
module multiplier(out, p1, p2, r, B_ext);
    parameter int d = `d;
    localparam B_ext = `B_ext;

    output logic [0:7+d] out;
    input logic [0:7+d] p1, p2;
    input logic [0:d-1] r;

    // partial products are extended to length 2m+2d-1, to reach the highest degree available by multiplication
    logic [0:7+d][0:14+2*d] partial_products;
    logic [0:6+d] overflow_sum;
    
    // Calculate the partial products
    genvar i;
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
            assign overflow_sum[i] = ^(partial_products[0:7+d][8+d+i]);
        end
    endgenerate

    // Use B_ext as a systematic encoder to get the modular reduction term (again, may need to transpose)
    // concatenation from the LEFT means lower bits, this is where we should add the refresh
    logic [0:7+d] reduction_term;
    generate
        for (i = 0; i < 8; i++) begin
            assign reduction_term[i] = ^({r, overflow_sum} & B_ext[0:0+6+2*d][i]);
        end
    endgenerate
    assign reduction_term[8:7+d] = r;

    // Calculate the final output using both the refresh and the sum of the partial products
    generate
        for (i = 0; i < 8+d; i++) begin
            assign out[i] = reduction_term[i] ^ (^(partial_products[0:7+d][i]));
        end
    endgenerate
endmodule
