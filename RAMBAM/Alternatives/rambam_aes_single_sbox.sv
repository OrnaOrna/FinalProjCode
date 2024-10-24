// A possible RAMBAM implementation with only a single S-Box, having less algorithmic noise and 
// being less costly, but taking longer and being more vulnerable. Development of this has stopped 
// due to time limitations and this module is incomplete.
module rambam_aes(clk, rst, plaintext, key, random_vect, ciphertext);
    // External parameters
    parameter int d = `d;
    parameter bit[0:8] P = `P;
    parameter bit[0:d] Q = `Q;
    
    // Derived parameters (all calculated inside in GLM, sadly)
    localparam bit[0:7+d] PQ = `PQ;
    localparam bit[0:7+d][0:7+d] W = `W;
    localparam bit[0:7+d] w = `w;
    localparam bit[0:7][0:7] L = `L;
    localparam bit[0:7+d][0:7+d] L_one = `L_one;
    localparam bit[0:7+d][0:7+d] L_two = `L_two;
    localparam bit[0:7+d][0:7+d] L_three = `L_three;
    localparam bit[0:7+d][0:7+d] pow1 = `pow1;
    localparam bit[0:7+d][0:7+d] pow2 = `pow2;
    localparam bit[0:7+d][0:7+d] pow4 = `pow4;
    // rcon - maybe? Need to talk this over

    input logic clk, rst;

    input logic [0:127] plaintext;
    input logic [0:127] key;
    input logic [0:22][0:d-1] random_vect;
    output logic [0:127] ciphertext;

    // Number of steps needed to complete each function
    // tentative values, not exact
    `define ROUNDS 10
    `define ROUND_BITS 4
    `define STAGES 5
    `define STAGE_BITS 3
    `define SBOX_CYCLES 7
    `define SBOX_BITS 3


    // Internal state counters
    logic [`ROUND_BITS - 1: 0] round_ctr;
    logic [`STAGE_BITS - 1: 0] stage_ctr;
    logic [`SBOX_BITS - 1: 0] sbox_ctr;


    always_ff @( posedge clk, posedge rst ) begin : init_and_states
        if (rst) begin
            round_ctr <= '{default:0};
            stage_ctr <= '{default:0};
            sbox_ctr <= '{default:0};
        end else begin

        end
    end


endmodule