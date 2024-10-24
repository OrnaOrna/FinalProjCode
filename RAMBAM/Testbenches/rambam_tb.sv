`timescale 1ns/1ps

interface rambam_aes_if;
    logic clk, rst;
    logic drdy_i, drdy_o;
    logic [0:127] plaintext;
    logic [0:127] key;

    logic [0:127] ciphertext;
    logic [0:22][0:`d-1] random_vect;
endinterface

module rambam_tb;
    rambam_aes_if rambam_aes_if_inst();

    string output_file = "../output.txt";
    int fd;

    always #5 rambam_aes_if_inst.clk = ~rambam_aes_if_inst.clk;

    initial begin
        rambam_aes_if_inst.clk = 1'b0;
        rambam_aes_if_inst.rst = 1'b1;
        rambam_aes_if_inst.drdy_i = 1'b0;    


        #10;

        rambam_aes_if_inst.rst = 1'b0;

        #10;

        rambam_aes_if_inst.drdy_i = 1'b1;
        rambam_aes_if_inst.plaintext = 128'h0123456789ABCDEF0123456789ABCDEF;
        rambam_aes_if_inst.key = 128'h0123456789ABCDEF0123456789ABCDEF;
        rambam_aes_if_inst.random_vect = '{default:4'd1};
        
        #10;

        rambam_aes_if_inst.drdy_i = 1'b0;

        @(rambam_aes_if_inst.drdy_o);
        #5;

        $display("ciphertext = %h", rambam_aes_if_inst.ciphertext);
       
        #10; 
 
        rambam_aes_if_inst.drdy_i = 1'b1;
        rambam_aes_if_inst.plaintext = 128'b1;
        rambam_aes_if_inst.key = 128'b1;
        #20;

        rambam_aes_if_inst.drdy_i = 1'b0;


        @(rambam_aes_if_inst.drdy_o);
        #5;

        $display("ciphertext = %h", rambam_aes_if_inst.ciphertext);
        $finish;
    end

    rambam_aes_multiple_sbox #(.d(`d), .P(`P), .Q(`Q)) rambam(
        .clk(rambam_aes_if_inst.clk), .rst(rambam_aes_if_inst.rst),
        .plaintext(rambam_aes_if_inst.plaintext),
        .key(rambam_aes_if_inst.key),
        .ciphertext(rambam_aes_if_inst.ciphertext),
        .random_vect(rambam_aes_if_inst.random_vect),
        .drdy_i(rambam_aes_if_inst.drdy_i),
        .drdy_o(rambam_aes_if_inst.drdy_o)
    );
endmodule
