// RAMBAM multiplier, with serial implementation, with refresh added after each atomic operation both
// to the accumulator and to the shifter. Note the significant use of randomness here and the added cost.
// of 2 matrix multipliers.
module multiplier(clk, rst, drdy_i, drdy_o, out, p1, p2, random_vect);
    parameter int d = `d;
    parameter bit[0:8+d] PQ = `PQ;



    output logic [0:7+d] out;
    input logic [0:7+d] p1, p2;
    input logic [2*(8+d)-1:0][0:d-1] random_vect;
    input logic clk, rst, drdy_i;
    output logic drdy_o;

    logic [0:7+d] accumulator, accumulator_next, shifter, refresh_shifter, refresh_accumulator;
    logic [0:$clog2(9+d)-1] shift_counter, shift_counter_next, shift_counter_capped;
    logic active;


    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            accumulator <= '0;
            shifter <= '0;
            shift_counter <= '0;
            active <= 1'b0;
        end else if (drdy_i) begin 
            active <= 1'b1;
            accumulator <= '0;
            shifter <= p2;
            shift_counter <= '0;
        end else if (active) begin
            if (shift_counter == 7+d) begin
                active <= 1'b0;
            end
            accumulator <= accumulator_next;
            shifter <= shifter_next;
            shift_counter <= shift_counter_next;
        end
    end

    always_comb begin
        out = accumulator;
        if (shift_counter == 8+d) begin
            shift_counter_capped = '0;
        end else begin
            shift_counter_capped = shift_counter;
        end
    end

    assign drdy_o = (shift_counter == 8+d);
    assign shift_counter_next = shift_counter + 1;
    assign accumulator_next = accumulator ^ refresh_accumulator ^ ({8+d{p1[shift_counter_capped]}} & shifter);
    assign shifter_next = {1'b0, shifter[1:7+d]} ^ refresh_shifter ^ ({8+d{shifter[7+d]}} & PQ[0:7+d]);
    mul_P #(.d(d), .P(P)) acc_refresher (.out(refresh_accumulator), .r(random_vect[shift_counter_capped]));
    mul_P #(.d(d), .P(P)) shf_refresher (.out(refresh_shifter), .r(random_vect[shift_counter_capped+(8+d)]));
endmodule
