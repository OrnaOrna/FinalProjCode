`include "multiplier_io.svh"
`include "clm_typedefs.svh"
import types::*;

// CLM multiplier with refresh in the CLM style, with serial implementation.
// 2*n (n-m)-bit random inputs are required.
module multiplier(inouts, random_vect, MC);
    parameter int d = d;

    multiplier_io_if.mul inouts;
    input red_poly_t[0:2*(8+d)-1] random_vect;
    input dn_matrix_t MC;

    
    // Accumulator holds during the i'th CC the sum up to p2_i. Shifter
    // holds p1 shifted and reduced i times.
    state_t accumulator, accumulator_next, shifter, shifter_next, refresh_accumulator;
    logic [0:$clog2(9+d)-1] shift_counter, shift_counter_next, shift_counter_capped;
    // Whether to continue counting or not. This is a very simple implementation of a state machine.
    logic active;
    // Which of the random inputs to use as the random Q for the random modular reduction
    red_poly_t q;
    // The random vector saved for the refresh
    red_poly_t[0:2*(8+d)-1] random_vect_saved;
    state_t p1_saved;

    // State transitions
    always_ff @(posedge inouts.clk or posedge inouts.rst) begin
        if (inouts.rst) begin
            accumulator <= '0;
            shifter <= '0;
            shift_counter <= '0;
            active <= 1'b0;
            p1_saved <= '0;
            random_vect_saved <= '0;
        end else if (inouts.drdy_i) begin 
            active <= 1'b1;
            accumulator <= '0;
            shifter <= inouts.p2;
            shift_counter <= '0;
            p1_saved <= inouts.p1;
            random_vect_saved <= random_vect;
        end else if (active) begin
            if (shift_counter == 7+d) begin
                active <= 1'b0;
            end
            accumulator <= accumulator_next;
            shifter <= shifter_next;
            shift_counter <= shift_counter_next;
        end
    end

    // Cap the counter so that no access to illegal data is made during the final
    // clock cycle. This datum is not used anyway, but to avoid synthesis errors
    // This safeguard is in place
    always_comb begin
        inouts.out = accumulator;
        if (shift_counter >= 8+d) begin
            shift_counter_capped = '0;
        end else begin
            shift_counter_capped = shift_counter;
        end
    end

    assign inouts.drdy_o = (shift_counter == 8+d);
    assign shift_counter_next = shift_counter + 1;
    assign accumulator_next = accumulator ^ refresh_accumulator ^ ({8+d{p1_saved[shift_counter_capped]}} & shifter);
    assign shifter_next = {1'b0, shifter[0:6+d]} ^ ({8+d{shifter[7+d]}} & pq);

    // Calculate PQ via mul_P
    assign q = random_vect[shift_counter_capped + (8+d)];
    state_t pq, pq_wo_msb;
    mul_P pq_calculator (.out(pq_wo_msb), .r(q), .M(MC));
    // XOR with P
    assign pq[d:7+d] = pq_wo_msb[d:7+d] ^ inouts.P[0:7];
    assign pq[0:d-1] = pq_wo_msb[0:d-1];


    mul_P acc_refresher (.out(refresh_accumulator), .r(random_vect_saved[shift_counter_capped]), .M(MC));
endmodule
