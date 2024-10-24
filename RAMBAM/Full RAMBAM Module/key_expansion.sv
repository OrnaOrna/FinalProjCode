module key_expansion(clk, rst, out, in, r, drdy_i, drdy_o, first_round);
    parameter int d = `d;
    parameter bit [0:8] P = `P;
    parameter bit [0:d] Q = `Q;
    parameter bit [0:7][0:7] L = `L; 


    input logic clk, rst;
    output logic drdy_o;
    input logic drdy_i, first_round;
    input logic [3:0][3:0][0:7+d] in;
    output logic [3:0][3:0][0:7+d] out;
    input logic [0:6][0:d-1] r;


    // Internal state counters
    logic [`SBOX_BITS - 1: 0] sbox_ctr, sbox_ctr_next;
    ks_stages_t stage_ctr, stage_ctr_next;

    // AES generator polynomial
    localparam bit[0:8] P0 = 9'b110110001; 

    // rcon
    logic [0:7] rc, rc_transformed, rc_next;
    logic [3:0][0:7+d] rcon;

    // Module outputs
    logic [3:0][0:7+d] rot_word_out, sub_word_out, word_saved;

    // Transposed input and output, since AES works in column-major order
    logic [3:0][3:0][0:7+d] in_transposed, out_transposed, out_transposed_saved;

    // Register enables
    logic sw_reg_en, rcon_reg_en, out_reg_en, rcon_reg_rst;

    // Loop variables
    genvar i, j;



    // Transpose inputs and outputs
    generate 
        for (i = 0; i < 4; i++) begin : gen_transpose_inout_o
            for (j = 0; j < 4; j++) begin : gen_transpose_inout_i
                assign in_transposed[j][i] = in[i][j];
                assign out[i][j] = out_transposed_saved[j][i];
            end
        end
    endgenerate

    // RotWord
    generate 
        for (i = 0; i < 4; i++) begin : gen_rot_word
            assign rot_word_out[i] = in_transposed[3][(i + 1) % 4];
        end
    endgenerate

    // SubWord
    generate 
        for (i = 0; i < 4; i++) begin : gen_sub_word
            rambam_sbox_storage #(.d(d), .P(P), .Q(Q)) sbox (
                .out(sub_word_out[i]),
                .plaintext(rot_word_out[i]),
                .r(r),
                .clk(clk),
                .rst(rst)
            );
        end
    endgenerate

    // Save output of SubWord
    register_word save_sub_word (
        .clk(clk),
        .rst(rst),
        .en(sw_reg_en),
        .in(sub_word_out),
        .out(word_saved)
    );

    // XOR stage
    always_comb begin : xor_stage
        rcon[0] = {rc_transformed, {d{1'b0}}};
        rcon[3:1] = '{default:0};
        out_transposed[0] = in_transposed[0] ^ word_saved ^ rcon;
        out_transposed[1] = in_transposed[1] ^ out_transposed[0];
        out_transposed[2] = in_transposed[2] ^ out_transposed[1];
        out_transposed[3] = in_transposed[3] ^ out_transposed[2];
    end

    // transform rc_i
    input_transform #(.L(L)) rc_transformer(.byte_o(rc_transformed), .byte_i(rc));

    // Generate next rc_i
    modular_shift #(.d(0), .PQ(P0)) rc_shifter (
        .in(rc),
        .out(rc_next)
    );

    // Save output of XOR
    generate 
        for (i = 0; i < 4; i++) begin : gen_out_regs
            register_word save_out (
                .clk(clk),
                .rst(rst),
                .en(out_reg_en),
                .in(out_transposed[i]),
                .out(out_transposed_saved[i])
            );
        end
    endgenerate

    // Assign register enables
    always_comb begin : reg_en
        sw_reg_en = (stage_ctr == SUB_WORD) && (sbox_ctr == `SBOX_CYCLES);
        rcon_reg_en = (stage_ctr == XOR);
        out_reg_en = (stage_ctr == XOR);
        rcon_reg_rst = (stage_ctr == KS_IDLE) && (first_round);
    end

    // State machine
    always_comb begin : state_machine
        drdy_o = 1'b0;
        stage_ctr_next = stage_ctr;
        sbox_ctr_next = '{default:0};
        case (stage_ctr)
            KS_IDLE: begin
                if (drdy_i) stage_ctr_next = SUB_WORD;
            end
            SUB_WORD: begin
                if (sbox_ctr == `SBOX_CYCLES) begin
                    stage_ctr_next = XOR;
                end else begin
                    sbox_ctr_next = sbox_ctr + 1;
                end
            end
            XOR: begin
                stage_ctr_next = OUT;
            end
            OUT: begin
                stage_ctr_next = KS_IDLE;
                drdy_o = 1'b1;
            end
            default: begin
            end
        endcase
    end

    // Update state machine
    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            stage_ctr <= KS_IDLE;
            sbox_ctr <= '{default:0};
            rc <= 8'd128;
        end else begin
            stage_ctr <= stage_ctr_next;
            sbox_ctr <= sbox_ctr_next;
            if (rcon_reg_rst) begin
               rc <= 8'd128;
            end
            if (rcon_reg_en) begin
               rc <= rc_next;
            end
        end
    end
endmodule

module register_word(clk, rst, en, in, out);
    parameter int d = `d;

    input logic clk, rst, en;
    input logic [3:0][0:7+d] in;
    output logic [3:0][0:7+d] out;

    always_ff @(posedge clk, posedge rst) begin
        if (rst) begin
            out <= '0;
        end else if (en) begin
            out <= in;
        end
    end
endmodule
