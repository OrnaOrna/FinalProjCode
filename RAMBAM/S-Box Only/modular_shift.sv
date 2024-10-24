// Multiplies the input by x (a shift), and reduces the result modulo a polynomial provided as a parameter.
module modular_shift(out, in);
    parameter int d = `d;
    parameter bit[0:8+d] PQ = `PQ;

    output logic [0:7+d] out;
    input logic [0:7+d] in;

    logic [0:8+d] out_no_modulo;
    assign out_no_modulo = {1'b0, in};

    // This should be optimized by the synthesizer, with all unnecessary and gates removed, so we 
    // do not need a generate block to create this.
    // The cloning is to AND the single MSB with the entire polynomial bus.
    assign out = out_no_modulo[0:7+d] ^ ({8+d{out_no_modulo[8+d]}} & PQ[0:7+d]);
endmodule
