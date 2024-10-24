module add_round_key(state_vec_o, state_vec_i, key);
    parameter int d = `d;
    input logic [3:0][3:0][0:7+d] state_vec_i;
    input logic [3:0][3:0][0:7+d] key;
    output logic [3:0][3:0][0:7+d] state_vec_o;

    genvar i, j;
    generate
        for (i = 0; i < 4; i++) begin : gen_outer
            for (j = 0; j < 4; j++) begin : gen_inner
                assign state_vec_o[i][j] = state_vec_i[i][j] ^ key[i][j];
            end
        end
    endgenerate
endmodule