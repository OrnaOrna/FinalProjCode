`include "clm_typedefs.svh"
import types::*;    

function automatic red_poly_t [0:6] shift_randomness;
    input red_poly_t [0:6] random_inp;
    input integer shamt;

    for (int i = 0; i < 7; i++) begin
        shift_randomness[i][0:d-1] = random_inp[(i + shamt) % 7][0:d-1];
    end
endfunction