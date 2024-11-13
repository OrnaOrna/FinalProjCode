// Testbench for the serial implementation of the multiplier module
module serial_mult_tb;

    // Parameters
    parameter int d = 8;
    parameter bit[8+d:0] PQ = {1'b1, 15'b0, 1'b1}; 
    

    // Inputs
    logic clk;
    logic rst;
    logic drdy_i;
    logic [0:7+d] p1;
    logic [0:7+d] p2;

    // Outputs
    logic drdy_o;
    logic [0:7+d] out;

    // Instantiate the Unit Under Test (UUT)
    multiplier #(.d(d), .PQ(PQ)) uut (
        .clk(clk),
        .rst(rst),
        .drdy_i(drdy_i),
        .drdy_o(drdy_o),
        .out(out),
        .p1(p1),
        .p2(p2)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // Test sequence
    initial begin
        // Initialize Inputs
        rst = '1;
        drdy_i = '0;
        p1 = '0;
        p2 = '0;

        // Wait for global reset
        #20;
        rst = 0;

        // Apply test vectors
        p1 = 16'h0001; // Example value, adjust as needed
        p2 = 16'h0001; // Example value, adjust as needed
        drdy_i = '1;
        #10;
        drdy_i = '0;

        // Wait for multiplication to complete
        wait (drdy_o == '1);
        #5;
        // Check result
        $display("Result: %h", out);

        // Finish simulation
        $finish;
    end

    initial begin
        $dumpfile("serial_mult_tb.vcd");
        $dumpvars(0, serial_mult_tb);
        $display("Starting simulation...");
    end
endmodule