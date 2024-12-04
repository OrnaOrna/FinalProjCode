`include "sub_bytes_io.svh"
`include "clm_typedefs.svh"
import types::*;

// Alternative implementation of the Sub-bytes stage (including the end registers)
// using 4 S-Boxes
module four_sbox(inouts, params);
    sub_bytes_io_if.basic inouts;
    params_if.in_use params;


endmodule