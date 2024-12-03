`include "clm_typedefs.svh"
import types::*;

// Input/output interface for a multiplier working in serial mode. Additional
// inputs vary according to the multiplier implementation.
interface multiplier_io_if();
    parameter int d = d;

    state_t p1, p2, out;
    
    logic clk, rst, drdy_i, drdy_o;
    base_poly_t P;

    modport mul(input clk, rst, p1, p2, P, drdy_i, output drdy_o, out);

endinterface