module mod_P(
    in, out
);
    parameter int d = 4;
    parameter bit[0:d-1][0:7] MODP_MAT = '{default:0};

    input logic [0:7+d] in;
    output logic [0:7] out;

    logic [0:7][0:d-1] matrix_transposed;
    genvar i,j;

    generate
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < d; j++) begin
                assign matrix_transposed[i][j] = MODP_MAT[j][i];
            end
        end
    endgenerate

    generate
        for (i = 0; i < 8; i++) begin
            assign out[i] = in[i] ^ (^(matrix_transposed[i] & in[8:7+d]));
        end
    endgenerate
endmodule
