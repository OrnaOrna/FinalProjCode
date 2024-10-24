

`timescale 1ns/1ps

module sbox_tb;
    logic clk; logic rst;
    logic [0:7+`d] in;
    logic [0:7+`d] out;
    logic [0:6][0:`d-1] r;

    string output_file = "../output.txt";
    int fd; 

    always #5 clk = ~clk;

    initial begin
        clk = 1'b0;
        in = 12'b0000_0000_0000;
        //in = 12'b011010000111;
        //r = {4'b1000, 4'b1000, 4'b0101, 4'b1000, 4'b1111, 4'b1111, 4'b1110};
        r = {4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0, 4'd0};

        rst = 1'b0;

        #10; 

        rst = 1'b1;

        #20;
        
        rst = 1'b0;

        #1000;

        $display("out = %b", out);
        $finish;
    end

    rambam_sbox_storage #(.d(`d), .P(`P), .Q(`Q)) sbox(.clk(clk), .rst(rst), .out(out), .plaintext(in), .r(r));
endmodule
