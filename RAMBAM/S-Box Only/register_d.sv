module register_d(out, in, clk, rst);
    parameter int d = `d;

    input logic clk;
    input logic rst; 
    input logic [7+d:0] in;
    output logic [7+d:0] out;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
        end else begin
            out <= in;
        end
    end
endmodule