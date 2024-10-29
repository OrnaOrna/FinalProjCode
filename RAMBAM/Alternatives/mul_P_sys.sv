module mul_P(out, r);
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    // Same matrix as for reduction modulo P
    localparam bit[0:d-1][0:7] MODP_MAT = `modPmat;


    output logic [0:7+d] out;
    input logic [0:d-1] r;

    assign out[8:7+d] = r;

    logic [0:7][0:d-1] matrix_transposed;

    genvar i, j;
    generate
        for (i = 0; i < 8; i++) begin
            for (j = 0; j < d; j++) begin
                assign matrix_transposed[i][j] = MODP_MAT[j][i];
            end
        end
    endgenerate

    genvar k;
    generate
        for (k = 0; k < 8; k++) begin
            assign out[k] = ^(r & matrix_transposed[k][0:d-1]);
        end
    endgenerate
endmodule
