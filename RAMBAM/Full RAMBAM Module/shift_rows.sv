module shift_rows(state_vec_o, state_vec_i);
    parameter int d = `d;

    // First index - row, second index - column
    input logic [3:0][3:0][0:7+d] state_vec_i;
    output logic [3:0][3:0][0:7+d] state_vec_o;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin
            for (j = 0; j < 4; j++) begin
                assign state_vec_o[i][j] = state_vec_i[i][(j+i) % 4];
            end
        end
    endgenerate
endmodule
