`include "clm_typedefs.svh"
import types::*;

interface sub_bytes_io_if;
    logic clk, rst;
    logic active, load_r, drdy_o;
    state_vec_t in, out;
    red_poly_t[0:6] random_vect;

    modport basic (
        input clk, rst, active, load_r, in, random_vect,
        output out, drdy_o
    );
endinterface