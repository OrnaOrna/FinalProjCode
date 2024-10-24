// RAMBAM multiplier, with serial implementation, with no refresh added.
// This is probably very cheap, but very vulnerable to SCA.
module multiplier(clk, rst, drdy_i, drdy_o, out, p1, p2);
    parameter int d = `d;
    parameter bit[0:8+d] PQ = `PQ;



    output logic [0:7+d] out;
    input logic [0:7+d] p1, p2;
    input logic clk, rst, drdy_i;
    output logic drdy_o;

    logic [0:7+d] accumulator, accumulator_next, shifter, shifter_next;
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
    assign accumulator_next = accumulator ^ ({8+d{p1[shift_counter_capped]}} & shifter);
    modular_shift #(.d(d), .PQ(PQ)) shifter_inst(.out(shifter_next), .in(shifter));
endmodule
