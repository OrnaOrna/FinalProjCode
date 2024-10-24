module mul_P(out, r);
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    localparam bit[0:d-1][0:7] MODP_MAT = `modPmat;

    output logic [0:7+d] out;
    input logic [0:d-1] r;

    logic [0:d-1][0:7+d] addend_table;
    logic [0:7+d][0:d-1] addend_table_transposed;


    genvar i, j;
    generate
        for (i = 0; i < d; i++) begin
            assign addend_table[i][i +: 9] = P;
            if (i !=  0)
                assign addend_table[i][0 : i-1] = '0;
            if (i != d-1)
                assign addend_table[i][i+9:7+d] = '0;
        end
    endgenerate
    generate
        for (i = 0; i < 8 + d; i++) begin
            for (j = 0; j < d; j++) begin
                assign addend_table_transposed[i][j] = addend_table[j][i];
            end
        end
    endgenerate
    
    genvar k;
    generate
        for (k = 0; k < 8 + d; k++) begin
            assign out[k] = ^(r & addend_table_transposed[k][0:d-1]);
        end
    endgenerate
endmodule
