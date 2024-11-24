`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/12/2024 11:35:33 PM
// Design Name: 
// Module Name: clm_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module clm_tb();
    clm_inouts_if clm_inouts();
    p_det_t p_det;
    red_poly_t [0:22] random_vect;
    
    initial begin
        clm_inouts.clk = 1'b0;
        forever #5 clm_inouts.clk = ~clm_inouts.clk;
    end
    
    initial begin
        clm_inouts.rst = 1'b1;
        clm_inouts.drdy_i = 1'b0;
        
        #10;
        clm_inouts.rst = 1'b0;
        
        #10;
        clm_inouts.drdy_i = 1'b1;
        clm_inouts.plaintext = 128'h0;
        clm_inouts.key = 128'h0;
        random_vect = '{default:7'd0};
        p_det = 5'd11;
        
        #10;

        clm_inouts.drdy_i = 1'b0;

        @(clm_inouts.drdy_o);
        #5;

        $display("ciphertext = %h", clm_inouts.ciphertext);
        $finish;
       
//        #10; 
 
//        clm_inouts.drdy_i = 1'b1;
//        clm_inouts.plaintext = 128'b1;
//        clm_inouts.key = 128'b1;
//        #20;

//        clm_inouts.drdy_i = 1'b0;


//        @(clm_inouts.drdy_o);
//        #5;

//        $display("ciphertext = %h", clm_inouts.ciphertext);
//        $finish;
    end 
        
    
    clm_aes_multiple_sbox_limited_p clm(.inouts(clm_inouts.basic), .p_det(p_det), .random_vect(random_vect));
endmodule
