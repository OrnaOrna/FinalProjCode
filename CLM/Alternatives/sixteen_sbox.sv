`include "sub_bytes_io.svh"
`include "clm_typedefs.svh"
import types::*;

// Alternative implementation of the Sub-bytes stage 
// (including the end registers & r storage) using 16 S-Boxes
module sixteen_sbox(inouts, params);
    sub_bytes_io_if.basic inouts;
    params_if.in_use params;

    red_poly_t[0:6] random_vect_saved;

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

            if (sbox_drdy) begin
                for (int i = 0; i < 4; i++) begin
                    for (int j = 0; j < 4; j++) begin
                        inouts.out[i][j] <= sbox_inouts[i][j].out;
                    end
                end
            end
        end
    end
    
    assign inouts.drdy_o = sbox_drdy;
    assign sbox_drdy = &sbox_drdys;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin : sbox_gen_outer
            for (j = 0; j < 4; j++) begin : sbox_gen_inner
                clm_sbox sbox_inst(
                    .inouts(sbox_inouts[i][j]),
                    .params(params)
                );

                assign sbox_inouts[i][j].clk = inouts.clk;
                assign sbox_inouts[i][j].rst = inouts.rst;
                assign sbox_inouts[i][j].drdy_i = inouts.active;
                assign sbox_inouts[i][j].in = inouts.in[i][j];
                assign sbox_inouts[i][j].r = shift_randomness(random_vect_saved, 4*i+j);
                assign sbox_drdys[i][j] = sbox_inouts[i][j].drdy_o;
            end
        end
    endgenerate
endmodule