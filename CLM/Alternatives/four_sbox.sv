`include "sub_bytes_io.svh"
`include "clm_typedefs.svh"
import types::*;

// Alternative implementation of the Sub-bytes stage 
// (including the end registers & r storage) using 4 S-Boxes
module four_sbox(inouts, params);
    sub_bytes_inouts_if.basic inouts;
    params_if.in_use params;

    red_poly_t[0:6] random_vect_saved;
    state_word_t out_unsaved;

    logic [0:1] counter, counter_next;
    assign counter_next = inouts.active ? counter + 1 : 2'b00;
    
    sbox_inouts_if sbox_inouts[0:3]();
    logic [0:3] sbox_drdys;
    logic sbox_drdy;

    always_ff @(posedge inouts.clk or posedge inouts.rst) begin
        if (inouts.rst) begin
            counter <= '0;
            random_vect_saved <= '0;
            inouts.out <= '0;
        end else if (inouts.active) begin
            if (inouts.load_r) begin
                random_vect_saved <= inouts.random_vect;
            end else if (sbox_drdy) begin
                random_vect_saved <= shift_randomness(random_vect_saved, 4);
            end

            if (sbox_drdy) begin
                inouts.out[counter] <= out_unsaved;
                counter <= counter_next;
            end
        end
    end
    
    assign inouts.drdy_o = (counter == 2'b11) & sbox_drdy;
    assign sbox_drdy = &sbox_drdys;

    genvar i;
    generate
        for (i = 0; i < 4; i++) begin : sbox_gen
            clm_sbox sbox_inst(
                .inouts(sbox_inouts[i]),
                .params(params)
            );

            assign sbox_inouts[i].clk = inouts.clk;
            assign sbox_inouts[i].rst = inouts.rst;
            assign sbox_inouts[i].drdy_i = inouts.active;
            assign sbox_inouts[i].in = inouts.in[counter][i];
            assign sbox_inouts[i].r = shift_randomness(random_vect_saved, i);
            assign sbox_drdys[i] = sbox_inouts[i].drdy_o;

            assign out_unsaved[i] = sbox_inouts[i].out;
        end
    endgenerate
endmodule