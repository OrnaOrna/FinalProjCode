// Raises to the power via a series of squaring operations. Each squaring is followed by a 
// modular reduction operation in the CLM style. The same randomness is used for all squaring operations;
// this may be problematic. This module is purely combinatorial, 
// and the squaring operations are laid one after another in space.
`include "clm_typedefs.svh"
import types::*;

module power(in, out, r, B_ext);
    parameter int d = d;
    parameter int pow = 0;

    input state_t in;
    input red_poly_t r;
    output state_t out;
    input mul_m_matrix_t B_ext;


    generate
        if (pow == 1) begin
            square squarer(.in(in), .out(out), .r(r), .B_ext(B_ext));
        end else if 
        (pow == 2) begin
            state_t squarer1_out;
            square squarer1(.in(in), .out(squarer1_out), .r(r), .B_ext(B_ext));
            square squarer2(.in(squarer1_out), .out(out), .r(r), .B_ext(B_ext));
        end else if (pow == 4) begin
            state_t squarer1_out, squarer2_out, squarer3_out;
            square squarer1(.in(in), .out(squarer1_out), .r(r), .B_ext(B_ext));
            square squarer2(.in(squarer1_out), .out(squarer2_out), .r(r), .B_ext(B_ext));
            square squarer3(.in(squarer2_out), .out(squarer3_out), .r(r), .B_ext(B_ext));
            square squarer4(.in(squarer3_out), .out(out), .r(r), .B_ext(B_ext));
        end else begin
            assign out = in;
        end
    endgenerate
endmodule
