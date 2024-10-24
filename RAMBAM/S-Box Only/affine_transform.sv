// Affine transformation module. Simply multiplies by the parameterized matrix then adds the parameterized vector.
module affine_transform(
    in, out
);
    parameter int d = 4;
    parameter bit[0:7+d][0:7+d] W = '{default:0};
    parameter bit[0:7+d] w = '{default:0};


    output logic [0:7+d] out;
    input logic [0:7+d] in;
    

    logic [0:7+d] lin_trans;
    matrix_mul #(.d(d), .matrix(W)) linear_transformer (
        .in(in),
        .out(lin_trans)
    );
    assign out = lin_trans ^ w;
endmodule
