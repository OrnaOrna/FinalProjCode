`include "clm_typedefs.svh"
`include "allL.svh"
`include "allP.svh"

import types::*;


module p_param_extractor(p_det, params);
    parameter int d = d;

    input p_det_t p_det;
    params_if.ext_p params;

    base_poly_t P;
    mm_matrix_t L, L_inv;
    genvar i;

    // For L, L_inv, P
    always_comb begin
        case (p_det)
            1: begin
                L = `L1;
                L_inv = `L_inv1;
                P = `P1;
            end
            2: begin
                L = `L2;
                L_inv = `L_inv2;
                P = `P2;
            end
            3: begin
                L = `L3;
                L_inv = `L_inv3;
                P = `P3;
            end
            4: begin
                L = `L4;
                L_inv = `L_inv4;
                P = `P4;
            end
            5: begin
                L = `L5;
                L_inv = `L_inv5;
                P = `P5;
            end
            6: begin
                L = `L6;
                L_inv = `L_inv6;
                P = `P6;
            end
            7: begin
                L = `L7;
                L_inv = `L_inv7;
                P = `P7;
            end
            8: begin
                L = `L8;
                L_inv = `L_inv8;
                P = `P8;
            end
            9: begin
                L = `L9;
                L_inv = `L_inv9;
                P = `P9;
            end
            10: begin
                L = `L10;
                L_inv = `L_inv10;
                P = `P10;
            end
            11: begin
                L = `L11;
                L_inv = `L_inv11;
                P = `P11;
            end
            12: begin
                L = `L12;
                L_inv = `L_inv12;
                P = `P12;
            end
            13: begin
                L = `L13;
                L_inv = `L_inv13;
                P = `P13;
            end
            14: begin
                L = `L14;
                L_inv = `L_inv14;
                P = `P14;
            end
            15: begin
                L = `L15;
                L_inv = `L_inv15;
                P = `P15;
            end
            16: begin
                L = `L16;
                L_inv = `L_inv16;
                P = `P16;
            end
            17: begin
                L = `L17;
                L_inv = `L_inv17;
                P = `P17;
            end
            18: begin
                L = `L18;
                L_inv = `L_inv18;
                P = `P18;
            end
            19: begin
                L = `L19;
                L_inv = `L_inv19;
                P = `P19;
            end
            20: begin
                L = `L20;
                L_inv = `L_inv20;
                P = `P20;
            end
            21: begin
                L = `L21;
                L_inv = `L_inv21;
                P = `P21;
            end
            22: begin
                L = `L22;
                L_inv = `L_inv22;
                P = `P22;
            end
            23: begin
                L = `L23;
                L_inv = `L_inv23;
                P = `P23;
            end
            24: begin
                L = `L24;
                L_inv = `L_inv24;
                P = `P24;
            end
            25: begin
                L = `L25;
                L_inv = `L_inv25;
                P = `P25;
            end
            26: begin
                L = `L26;
                L_inv = `L_inv26;
                P = `P26;
            end
            27: begin
                L = `L27;
                L_inv = `L_inv27;
                P = `P27;
            end
            28: begin
                L = `L28;
                L_inv = `L_inv28;
                P = `P28;
            end
            29: begin
                L = `L29;
                L_inv = `L_inv29;
                P = `P29;
            end
            30: begin
                L = `L30;
                L_inv = `L_inv30;
                P = `P30;
            end
            default: begin
                L = 'x;
                L_inv = 'x;
                P = 'x;
            end
        endcase
    end
    assign params.P = P;
    assign params.L = L;
    assign params.L_inv = L_inv;

    // For MC, simply shifted copies of P
    assign params.MC = '{default:0};
    generate
        for (i = 0; i < d; i++) begin
            assign params.MC[i][i +: 9] = P;
        end
    endgenerate

    // For B, using degenerate instances of modular_shift
    assign params.B[0][0:7+d] = params.P;
    generate
        for (i = 1; i < d; i++) begin
            modular_shift #(.d(0)) modular_shift_inst(
                .out(params.B[i]),
                .in(params.B[i - 1]),
                .poly(params.P[0:7])
            );
        end
    endgenerate
endmodule
