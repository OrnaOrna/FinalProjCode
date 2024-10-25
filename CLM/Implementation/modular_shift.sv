// Performs a multiplication by x (shift) then reduction modulo poly
`include "clm_typedefs.svh"
import types::*;


module modular_shift(out, in, poly);
    parameter int d = d;

    input state_t in, poly;
    output state_t out;

    assign out = {1'b0, in[1:7+d]} ^ ({8+d{in[7+d]}} & poly);
endmodule