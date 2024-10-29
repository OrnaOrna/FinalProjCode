// CLM multiplier (PQ passed as input), serial implementation, with no refresh added.
// This could possibly be very hard to analyze, and is moderately expensive. 

`include "clm_typedefs.svh"
import types::*;

module multiplier(out, p1, p2, PQ);
    parameter int d = d;
    

    output state_t out;
    input state_t p1, p2, PQ;

    // see report for details
    state_t cout[0:8+d];
    state_t deg[0:7+d];
    genvar i;
    generate
        for (i = 0; i < 8+d; i++) begin
            if (i == 0) begin
                assign deg[i] = p2;
                assign cout[i] = 0;
            end
            if (i != 7+d)
                modular_shift modular_shift_inst(.out(deg[i+1]), .in(deg[i]), .poly(PQ));
            assign cout[i+1] = cout[i] ^ ({8+d{p1[i]}}&deg[i]);
        end
    endgenerate
    assign out = cout[8+d];
endmodule
