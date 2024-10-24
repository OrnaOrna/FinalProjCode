// RAMBAM multiplier, with serial implementation, with no refresh added.
// This could possibly be very hard to analyze, and is moderately expensive. 
module multiplier(out, p1, p2);
    parameter int d = `d;
    parameter bit[0:8+d] PQ = `PQ;

    output logic [0:7+d] out;
    input logic [0:7+d] p1;
    input logic [0:7+d] p2;

    // see design document for details
    logic [0:7+d] cout[0:8+d];
    logic [0:7+d] deg[0:7+d];
    genvar i;
    generate
        for (i = 0; i < 8+d; i++) begin
            if (i == 0) begin
                assign deg[i] = p2;
                assign cout[i] = 0;
            end
            if (i != 7+d)
                modular_shift #(.d(d), .PQ(PQ)) modular_shift_inst(.out(deg[i+1]), .in(deg[i]));
            assign cout[i+1] = cout[i] ^ ({8+d{p1[i]}}&deg[i]);
        end
    endgenerate
    assign out = cout[8+d];
endmodule
