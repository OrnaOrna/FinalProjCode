module input_transform(byte_o, byte_i);
    parameter bit[0:7][0:7] L = `L;

    input logic [0:7] byte_i;
    output logic [0:7] byte_o;

    matrix_mul #(.d(0), .matrix(L)) linear_transformer (
        .in(byte_i),
        .out(byte_o)
    );
endmodule
