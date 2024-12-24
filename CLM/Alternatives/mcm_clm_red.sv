`include "multiplier_io.svh"
`include "clm_typedefs.svh"
import types::*;

module mcm_clm_red(clk, rst, drdy_i, drdy_o, p1, p2, out, random_vect, p_det);
    input clk, rst, drdy_i;
    output drdy_o;

    input state_t p1, p2;
    output state_t out;
    input red_poly_t [0:8+d] random_vect;

    input p_det_t p_det;

    multiplier_io_if inouts();
    params_if params();
    assign inouts.P = params.P;

    assign inouts.clk = clk;
    assign inouts.rst = rst;
    assign inouts.drdy_i = drdy_i;
    assign inouts.p1 = p1;
    assign inouts.p2 = p2;
    assign out = inouts.out;
    assign drdy_o = inouts.drdy_o;

    p_param_extractor extractor (
        .p_det(p_det),
        .params(params.ext_p)
    );
    
    multiplier mul (.inouts(inouts.mul), .random_vect(random_vect), .MC(params.MC), .B_ext(params.B_ext));
endmodule