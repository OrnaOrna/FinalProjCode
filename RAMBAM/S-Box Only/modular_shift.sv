module modular_shift(out, in);
    parameter int d = `d;
    parameter bit[0:8+d] PQ = `PQ;

    output logic [0:7+d] out;
    input logic [0:7+d] in;

    logic [0:8+d] out_no_modulo;
    assign out_no_modulo = {1'b0, in};

    // Should be optimized by the synthesizer, so no need for a generate block
    assign out = out_no_modulo[0:7+d] ^ ({8+d{out_no_modulo[8+d]}} & PQ[0:7+d]);
endmodule
