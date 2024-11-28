`include "multiplier_io.svh"
`include "clm_typedefs.svh"
import types::*;

// CLM multiplier with refresh in the CLM style, with serial implementation.
// n+1 (n-m)-bit random inputs are required (maybe?).
// TODO: Important question to ask Itamar/Osnat: should the inputs to the modular reduction be 
// "hidden" (zeroed) before the clock cycle in which they are used? Or is masking
// fine even without this? I assume the former for now, the latter permits 
// a simpler implementation so it'll be easy to change to it.
module multiplier(inouts, random_vect, MC, B_ext);
    parameter int d = d;

    multiplier_io_if.mul inouts;
    input red_poly_t[0:8+d] random_vect;
    input dn_matrix_t MC;
    input mul_m_matrix_t B_ext;
    
    // Accumulator holds during the i'th CC the sum up to p2_i.
    logic [0:6+2*d] accumulator, accumulator_next;
    state_t refresh_accumulator, to_xor;

    // Variables for the post-multiplication modular reduction
    state_t reduction_term, post_reduction;
    red_poly_t q;
    logic[0:6+d] overflow;
    genvar i, j;


    // Storage for the operands
    state_t p1_saved, p2_saved;
    red_poly_t [0:8+d] random_vect_saved;
    

    logic [0:$clog2(9+d)-1] counter, counter_next, counter_capped;
    // Whether to continue counting or not. This is a very simple implementation of a state machine.
    logic active;
    // Whether it is the clock cycle for modular reduction or for accumulation
    logic final_cycle;

    // State transitions
    always_ff @(posedge inouts.clk or posedge inouts.rst) begin
        if (inouts.rst) begin
            accumulator <= '0;
            p1_saved <= '0;
            p2_saved <= '0;
            random_vect_saved <= '0;
            counter <= '0;
            active <= 1'b0;
        end else if (inouts.drdy_i) begin 
            active <= 1'b1;
            accumulator <= '0;
            p1_saved <= inouts.p1;
            p2_saved <= inouts.p2;
            random_vect_saved <= random_vect;
            counter <= '0;
        end else if (active) begin
            if (final_cycle) begin
                active <= 1'b0;
            end
            accumulator <= accumulator_next;
            counter <= counter_next;
        end
    end

    // Cap the counter so that no access to illegal data is made during the final
    // clock cycle. This datum is not used anyway, but to avoid synthesis errors
    // This safeguard is in place
    always_comb begin
        
        if (counter >= 8+d) begin
            counter_capped = '0;
        end else begin
            counter_capped = counter;
        end
    end

    assign inouts.drdy_o = (counter == 9+d);
    assign inouts.out = post_reduction;
    assign counter_next = counter + 1;
    assign final_cycle = (counter == 8+d);

    // Calculate the next accumulator value
    // TODO: debug this, this is experimental syntax
    assign to_xor = p1_saved[counter_capped] ? p2_saved : '0;
    assign accumulator_next = final_cycle ? accumulator : 
                xor_bits(accumulator, to_xor, refresh_accumulator, counter_capped);


    // "Hide" the inputs to the modular reduction before the final clock cycle
    assign overflow = final_cycle ? accumulator[8+d:6+2*d] : '0;
    assign q = final_cycle ? random_vect_saved[8+d] : '0;

    // Calculate the modular reduction
    generate
        for (i = 0; i < 8; i++) begin
            logic[0:6+2*d] column;
            for (j = 0; j < 7+2*d; j++) begin
                assign column[j] = B_ext[j][i];
            end
            assign reduction_term[i] = ^({q, overflow} & column);
        end
    endgenerate 
    assign reduction_term[8:7+d] = q;
    assign post_reduction = reduction_term ^ accumulator[0:7+d];

    // Calculate the refresh
    mul_P acc_refresher (.out(refresh_accumulator), .r(random_vect[counter_capped]), .M(MC));

    // Function that should hopefully XOR only the correct bits at each clock cycle
    // used for updating only the relevant bits in the accumulator
    function automatic state_t xor_bits(
        input logic[0:6+2*d] a,
        input state_t b,
        input state_t c,
        input logic [0:$clog2(9+d)-1] i);
        
        for (int j = 0; j < 7+2*d; j++) begin
            if (j < i) begin
                xor_bits[j] = a[j];
            end else if (j >= i && j < i+8+d) begin
                xor_bits[j] = a[j] ^ b[j] ^ c[j];
            end else begin
                xor_bits[j] = a[j];
            end
        end
    endfunction
endmodule
