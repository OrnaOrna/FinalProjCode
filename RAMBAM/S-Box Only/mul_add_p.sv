// Implementation as in the RAMBAM paper. As we've talked with Osnat about, this implementation has a weakness (probably, untested)
module mul_add_p(out, in, r);
    parameter int d = `d;
    parameter bit[0:8] P = `P;

    output logic [0:7+d] out;
    input logic [0:7+d] in;
    input logic [0:d-1] r;

    logic [0:7+d] rP;
    mul_P #(.d(d), .P(P)) mul_P_inst(.out(rP), .r(r));
    assign out = in ^ rP;
endmodule
