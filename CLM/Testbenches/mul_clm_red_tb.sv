`timescale 1ns / 1ps

`include "multiplier_io.svh"
`include "clm_typedefs.svh"
import types::*;


module mul_clm_red_tb();
    multiplier_io_if inouts();
    params_if params();
    assign inouts.P = params.P;
    

    red_poly_t [0:8+d] random_vect;
    p_det_t p_det;

    initial begin
        inouts.clk = 1'b0;
        forever #5 inouts.clk = ~inouts.clk;
    end
    
    initial begin
        inouts.rst = 1'b1;
        inouts.drdy_i = 1'b0;
        
        #10;
        inouts.rst = 1'b0;
        
        #10;
        inouts.drdy_i = 1'b1;
        inouts.p1 = 16'h123f;
        inouts.p2 = 16'h123f;
        random_vect = '{default:8'd34};
        p_det = 5'd13;
                
        #10;

        inouts.drdy_i = 1'b0;

        @(inouts.drdy_o);
        #5;

        $display("mul = %h", inouts.out);
        $finish;
    end
    

    p_param_extractor extractor (
        .p_det(p_det),
        .params(params)
    );
    multiplier mul (.inouts(inouts.mul), .random_vect(random_vect), .MC(params.MC), .B_ext(params.B_ext)); 
endmodule
