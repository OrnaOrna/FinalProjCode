`include "clm_typedefs.svh"
`include "allL.svh"
`include "allP.svh"
`include "allLinv.svh"
`include "allW11.svh"
`include "allW21 8.vh"
`include "allw 8.vh"

import types::*;

module p_param_extractor(p_det, params);
    parameter int d = d;

    input p_det_t p_det;
    params_if.ext_p params;

    base_poly_t P;
    mm_matrix_t L, Linv;
    dm_matrix_t T11, T21;
    state_t t;
    genvar i;

    // For L, Linv, P, T11, T21, t
    always_comb begin
        case (p_det)
            5'd1: begin
                L = `L1;
                Linv = `Linv1;
                P = `P1;
                T11 = `W11_1;
                T21 = `W21_1;
                t = `w1;
            end
            5'd2: begin
                L = `L2;
                Linv = `Linv2;
                P = `P2;
                T11 = `W11_2;
                T21 = `W21_2;
                t = `w2;
            end
            5'd3: begin
                L = `L3;
                Linv = `Linv3;
                P = `P3;
                T11 = `W11_3;
                T21 = `W21_3;
                t = `w3;
            end
            5'd4: begin
                L = `L4;
                Linv = `Linv4;
                P = `P4;
                T11 = `W11_4;
                T21 = `W21_4;
                t = `w4;
            end
            5'd5: begin
                L = `L5;
                Linv = `Linv5;
                P = `P5;
                T11 = `W11_5;
                T21 = `W21_5;
                t = `w5;
            end
            5'd6: begin
                L = `L6;
                Linv = `Linv6;
                P = `P6;
                T11 = `W11_6;
                T21 = `W21_6;
                t = `w6;
            end
            5'd7: begin
                L = `L7;
                Linv = `Linv7;
                P = `P7;
                T11 = `W11_7;
                T21 = `W21_7;
                t = `w7;
            end
            5'd8: begin
                L = `L8;
                Linv = `Linv8;
                P = `P8;
                T11 = `W11_8;
                T21 = `W21_8;
                t = `w8;
            end
            5'd9: begin
                L = `L9;
                Linv = `Linv9;
                P = `P9;
                T11 = `W11_9;
                T21 = `W21_9;
                t = `w9;
            end
            5'd10: begin
                L = `L10;
                Linv = `Linv10;
                P = `P10;
                T11 = `W11_10;
                T21 = `W21_10;
                t = `w10;
            end
            5'd11: begin
                L = `L11;
                Linv = `Linv11;
                P = `P11;
                T11 = `W11_11;
                T21 = `W21_11;
                t = `w11;
            end
            5'd12: begin
                L = `L12;
                Linv = `Linv12;
                P = `P12;
                T11 = `W11_12;
                T21 = `W21_12;
                t = `w12;
            end
            5'd13: begin
                L = `L13;
                Linv = `Linv13;
                P = `P13;
                T11 = `W11_13;
                T21 = `W21_13;
                t = `w13;
            end
            5'd14: begin
                L = `L14;
                Linv = `Linv14;
                P = `P14;
                T11 = `W11_14;
                T21 = `W21_14;
                t = `w14;
            end
            5'd15: begin
                L = `L15;
                Linv = `Linv15;
                P = `P15;
                T11 = `W11_15;
                T21 = `W21_15;
                t = `w15;
            end
            5'd16: begin
                L = `L16;
                Linv = `Linv16;
                P = `P16;
                T11 = `W11_16;
                T21 = `W21_16;
                t = `w16;
            end
            5'd17: begin
                L = `L17;
                Linv = `Linv17;
                P = `P17;
                T11 = `W11_17;
                T21 = `W21_17;
                t = `w17;
            end
            5'd18: begin
                L = `L18;
                Linv = `Linv18;
                P = `P18;
                T11 = `W11_18;
                T21 = `W21_18;
                t = `w18;
            end
            5'd19: begin
                L = `L19;
                Linv = `Linv19;
                P = `P19;
                T11 = `W11_19;
                T21 = `W21_19;
                t = `w19;
            end
            5'd20: begin
                L = `L20;
                Linv = `Linv20;
                P = `P20;
                T11 = `W11_20;
                T21 = `W21_20;
                t = `w20;
            end
            5'd21: begin
                L = `L21;
                Linv = `Linv21;
                P = `P21;
                T11 = `W11_21;
                T21 = `W21_21;
                t = `w21;
            end
            5'd22: begin
                L = `L22;
                Linv = `Linv22;
                P = `P22;
                T11 = `W11_22;
                T21 = `W21_22;
                t = `w22;
            end
            5'd23: begin
                L = `L23;
                Linv = `Linv23;
                P = `P23;
                T11 = `W11_23;
                T21 = `W21_23;
                t = `w23;
            end
            5'd24: begin
                L = `L24;
                Linv = `Linv24;
                P = `P24;
                T11 = `W11_24;
                T21 = `W21_24;
                t = `w24;
            end
            5'd25: begin
                L = `L25;
                Linv = `Linv25;
                P = `P25;
                T11 = `W11_25;
                T21 = `W21_25;
                t = `w25;
            end
            5'd26: begin
                L = `L26;
                Linv = `Linv26;
                P = `P26;
                T11 = `W11_26;
                T21 = `W21_26;
                t = `w26;
            end
            5'd27: begin
                L = `L27;
                Linv = `Linv27;
                P = `P27;
                T11 = `W11_27;
                T21 = `W21_27;
                t = `w27;
            end
            5'd28: begin
                L = `L28;
                Linv = `Linv28;
                P = `P28;
                T11 = `W11_28;
                T21 = `W21_28;
                t = `w28;
            end
            5'd29: begin
                L = `L29;
                Linv = `Linv29;
                P = `P29;
                T11 = `W11_29;
                T21 = `W21_29;
                t = `w29;
            end
            5'd30: begin
                L = `L30;
                Linv = `Linv30;
                P = `P30;
                T11 = `W11_30;
                T21 = `W21_30;
                t = `w30;
            end
            default: begin
                L = 'x;
                Linv = 'x;
                P = 'x;
                T11 = 'x;
                T21 = 'x;
                t = 'x;
            end
        endcase
    end

    assign params.P = P;
    assign params.L = L;
    assign params.Linv = Linv;
    assign params.T11 = T11;
    assign params.T21 = T21;
    assign params.t = t;

    // For MC, simply shifted copies of P
    assign params.MC = '{default:0};
    generate
        for (i = 0; i < d; i++) begin
            assign params.MC[i][i +: 9] = P;
        end
    endgenerate

    // For B and its extensions, use degenerate instances of modular_shift
    assign params.B_ext[0][0:7] = params.P[0:7];
    generate
        for (i = 1; i < 6+2*d+1; i++) begin
            assign params.B_ext[i][0:7] = {1'b0, params.B_ext[i-1][0:6]} ^ ({8{params.B_ext[i-1][7]}} & params.P[0:7]);
        end
    endgenerate
    
    for (i = 0; i < 7 + d; i ++) begin
        assign params.B_ext_MC[i][0:7] = params.B_ext[i][0:7];
    end
    for (i = 0; i < d; i ++) begin
        assign params.B[i][0:7] = params.B_ext[i][0:7];
    end

    // For T, generate the block matrix
    genvar j;
    generate
        for (i = 0; i < 8+d; i++) begin
            for (j = 0; j < 8+d; j++) begin
                // Upper left block
                if (i < 8 && j < 8) begin
                    assign params.T[i][j] = params.T11[i][j];
                end
                else if (i >= 8 && j < 8) begin
                    assign params.T[i][j] = params.T21[i-8][j];
                end
                else if (i < 8 && j >= 8) begin
                    assign params.T[i][j] = 1'b0;
                end
                else begin
                    if (i == j) begin
                        assign params.T[i][j] = 1'b1;
                    end
                    else begin
                        assign params.T[i][j] = 1'b0;
                    end
                end
            end
        end
    endgenerate
endmodule