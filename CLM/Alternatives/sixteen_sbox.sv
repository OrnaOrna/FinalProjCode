`include "sub_bytes_io.svh"
`include "clm_typedefs.svh"
import types::*;

// Alternative implementation of the Sub-bytes stage 
// (including the end registers & r storage) using 16 S-Boxes
module sixteen_sbox(inouts, params);
    sub_bytes_inouts_if.basic inouts;
    params_if.in_use params;

    red_poly_t[0:6] random_vect_saved;
    state_vec_t out_unsaved;

    sbox_inouts_if sbox_inouts[0:3][0:3]();
    logic [0:3][0:3] sbox_drdys;
    logic sbox_drdy;

    always_ff @(posedge inouts.clk or posedge inouts.rst) begin
        if (inouts.rst) begin
            random_vect_saved <= '0;
            inouts.out <= '0;
        end else if (inouts.active) begin
            if (inouts.load_r) begin
                random_vect_saved <= inouts.random_vect;
            end else if (sbox_drdy) begin
                random_vect_saved <= shift_randomness(random_vect_saved, 16);
            end

            inouts.out <= out_unsaved;
        end
    end
    
    assign inouts.drdy_o = sbox_drdy;
    assign sbox_drdy = &sbox_drdys;

    genvar k, l;
    generate
        for (k = 0; k < 4; k++) begin : sbox_gen_outer
            for (l = 0; l < 4; l++) begin : sbox_gen_inner
                clm_sbox sbox_inst(
                    .inouts(sbox_inouts[k][l]),
                    .params(params)
                );

                assign sbox_inouts[k][l].clk = inouts.clk;
                assign sbox_inouts[k][l].rst = inouts.rst;
                assign sbox_inouts[k][l].drdy_i = inouts.active;
                assign sbox_inouts[k][l].in = inouts.in[k][l];
                assign sbox_inouts[k][l].r = shift_randomness(random_vect_saved, 4*k+l);
                assign sbox_drdys[k][l] = sbox_inouts[k][l].drdy_o;

                assign out_unsaved[k][l] = sbox_inouts[k][l].out;
            end
        end
    endgenerate
endmodule