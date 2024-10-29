/*-------------------------------------------------------------------------
 AIST-LSI compatible local bus I/F for AES_Comp on FPGA
 *** NOTE *** 
 This circuit works only with AES_Comp.
 Compatibility for another cipher module may be provided in future release.
 
 File name   : lbus_if.v
 Version     : 1.3
 Created     : APR/02/2012
 Last update : APR/11/2012
 Desgined by : Toshihiro Katashita
 
 
 Copyright (C) 2012 AIST
 
 By using this code, you agree to the following terms and conditions.
 
 This code is copyrighted by AIST ("us").
 
 Permission is hereby granted to copy, reproduce, redistribute or
 otherwise use this code as long as: there is no monetary profit gained
 specifically from the use or reproduction of this code, it is not sold,
 rented, traded or otherwise marketed, and this copyright notice is
 included prominently in any copy made.
 
 We shall not be liable for any damages, including without limitation
 direct, indirect, incidental, special or consequential damages arising
 from the use of this code.
 
 When you publish any results arising from the use of this code, we will
 appreciate it if you can cite our webpage.
(http://www.risec.aist.go.jp/project/sasebo/)
 -------------------------------------------------------------------------*/ 


//================================================ LBUS_IF
module LBUS_IF
  (lbus_a, lbus_di, lbus_do, lbus_wr, lbus_rd, // Local bus
   blk_kin, blk_din, blk_dout, blk_krdy, blk_drdy, blk_kvld, blk_dvld,
   blk_encdec, blk_en, blk_rstn,
   clk, rst);                                  // Clock and reset
   
   //------------------------------------------------
   // Local bus
   input [15:0]   lbus_a;  // Address
   input [15:0]   lbus_di; // Input data  (Controller -> Cryptographic module)
   input          lbus_wr; // Assert input data
   input          lbus_rd; // Assert output data
   output [15:0]  lbus_do; // Output data (Cryptographic module -> Controller)

   // Block cipher
   output [127:0] blk_kin;
   output [495:0] blk_din;
   input  [127:0] blk_dout;
   output         blk_krdy, blk_drdy;
   input          blk_kvld, blk_dvld;
   output         blk_encdec, blk_en;
   output         blk_rstn;

   // Clock and reset
   input         clk, rst;

   //------------------------------------------------
   reg [15:0]    lbus_do;

   reg [127:0]   blk_kin;
   reg [495:0]   blk_din;
   reg           blk_krdy;
   reg [127:0] 	 blk_dout_reg;
   wire          blk_drdy;
   reg           blk_encdec;
   wire          blk_en = 1;
   reg           blk_rstn;
   
   reg [1:0]     wr;
   reg           trig_wr;
   wire          ctrl_wr;
   reg [2:0]     ctrl;
   reg [3:0]     blk_trig;

   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) wr <= 2'b00;
     else     wr <= {wr[0],lbus_wr};
   
   always @(posedge clk or posedge rst)
     if (rst)            trig_wr <= 0;
     else if (wr==2'b01) trig_wr <= 1;
     else                trig_wr <= 0;
   
   assign ctrl_wr = (trig_wr & (lbus_a==16'h0002));
   
   always @(posedge clk or posedge rst) 
     if (rst) ctrl <= 3'b000;
     else begin
        if (blk_drdy)       ctrl[0] <= 1;
        else if (|blk_trig) ctrl[0] <= 1;
        else if (blk_dvld)  ctrl[0] <= 0;

        if (blk_krdy)      ctrl[1] <= 1;
        else if (blk_kvld) ctrl[1] <= 0;
        
        ctrl[2] <= ~blk_rstn;
     end

   always @(posedge clk or posedge rst) 
     if (rst)           blk_dout_reg <= 128'h0;
     else if (blk_dvld) blk_dout_reg <= blk_dout;
   
   always @(posedge clk or posedge rst) 
     if (rst)          blk_trig <= 4'h0;
     else if (ctrl_wr) blk_trig <= {lbus_di[0],3'h0};
     else              blk_trig <= {1'h0,blk_trig[3:1]};
   assign blk_drdy = blk_trig[0];

   always @(posedge clk or posedge rst) 
     if (rst)          blk_krdy <= 0;
     else if (ctrl_wr) blk_krdy <= lbus_di[1];
     else              blk_krdy <= 0;

   always @(posedge clk or posedge rst) 
     if (rst)          blk_rstn <= 1;
     else if (ctrl_wr) blk_rstn <= ~lbus_di[2];
     else              blk_rstn <= 1;
   
   //------------------------------------------------
   always @(posedge clk or posedge rst) begin
      if (rst) begin
         blk_encdec <= 0;
         blk_kin <= 128'h0;
         blk_din <= 128'h0;
      end else if (trig_wr) begin
        case (lbus_a)
            16'h000C: blk_encdec <= lbus_di[0];
            16'h0100: blk_kin[127:112] <= lbus_di;
            16'h0102: blk_kin[111: 96] <= lbus_di;  
            16'h0104: blk_kin[ 95: 80] <= lbus_di;  
            16'h0106: blk_kin[ 79: 64] <= lbus_di;  
            16'h0108: blk_kin[ 63: 48] <= lbus_di;  
            16'h010A: blk_kin[ 47: 32] <= lbus_di;  
            16'h010C: blk_kin[ 31: 16] <= lbus_di;     
            16'h010E: blk_kin[ 15:  0] <= lbus_di;
            
            16'h0126: blk_din[495:480] <= lbus_di;
            16'h0128: blk_din[479:464] <= lbus_di;
            16'h012A: blk_din[463:448] <= lbus_di;
            16'h012C: blk_din[447:432] <= lbus_di;
            16'h012E: blk_din[431:416] <= lbus_di;
            16'h0130: blk_din[415:400] <= lbus_di;
            16'h0132: blk_din[399:384] <= lbus_di;
            16'h0134: blk_din[383:368] <= lbus_di;
            16'h0136: blk_din[367:352] <= lbus_di;
            16'h0138: blk_din[351:336] <= lbus_di;
            16'h013A: blk_din[335:320] <= lbus_di;
            16'h013C: blk_din[319:304] <= lbus_di;
            16'h013E: blk_din[303:288] <= lbus_di;
            16'h0140: blk_din[495:480] <= lbus_di;
            16'h0142: blk_din[479:464] <= lbus_di;
            16'h0144: blk_din[463:448] <= lbus_di;
            16'h0146: blk_din[447:432] <= lbus_di;
            16'h0148: blk_din[431:416] <= lbus_di;
            16'h014a: blk_din[415:400] <= lbus_di;
            16'h014c: blk_din[399:384] <= lbus_di;
            16'h014e: blk_din[383:368] <= lbus_di;
            16'h0150: blk_din[367:352] <= lbus_di;
            16'h0152: blk_din[351:336] <= lbus_di;
            16'h0154: blk_din[335:320] <= lbus_di;
            16'h0156: blk_din[319:304] <= lbus_di;
            16'h0158: blk_din[303:288] <= lbus_di;
            16'h015a: blk_din[287:272] <= lbus_di;
            16'h015c: blk_din[271:256] <= lbus_di;
            16'h015e: blk_din[255:240] <= lbus_di;
            16'h0160: blk_din[239:224] <= lbus_di;
            16'h0162: blk_din[223:208] <= lbus_di;
            16'h0164: blk_din[207:192] <= lbus_di;
            16'h0166: blk_din[191:176] <= lbus_di;
            16'h0168: blk_din[175:160] <= lbus_di;
            16'h016a: blk_din[159:144] <= lbus_di;
            16'h016c: blk_din[143:128] <= lbus_di;
            16'h016e: blk_din[127:112] <= lbus_di;
            16'h0170: blk_din[111:96] <= lbus_di;
            16'h0172: blk_din[95:80] <= lbus_di;
            16'h0174: blk_din[79:64] <= lbus_di;
            16'h0176: blk_din[63:48] <= lbus_di;
            16'h0178: blk_din[47:32] <= lbus_di;
            16'h017a: blk_din[31:16] <= lbus_di;
            16'h017c: blk_din[15:0] <= lbus_di;           
        endcase
      end
   end
                
   //------------------------------------------------
   always @(posedge clk or posedge rst)
     if (rst) 
       lbus_do <= 16'h0;
     else if (~lbus_rd)
       lbus_do <= mux_lbus_do(lbus_a, ctrl, blk_encdec, blk_dout);
   
   function  [15:0] mux_lbus_do;
      input [15:0]   lbus_a;
      input [2:0]    ctrl;
      input          blk_encdec;
      input [127:0]  blk_dout;
      
      case(lbus_a)
        16'h0002: mux_lbus_do = ctrl;
        16'h000C: mux_lbus_do = blk_encdec;
        16'h0180: mux_lbus_do = blk_dout_reg[127:112];
        16'h0182: mux_lbus_do = blk_dout_reg[111:96];
        16'h0184: mux_lbus_do = blk_dout_reg[95:80];
        16'h0186: mux_lbus_do = blk_dout_reg[79:64];
        16'h0188: mux_lbus_do = blk_dout_reg[63:48];
        16'h018A: mux_lbus_do = blk_dout_reg[47:32];
        16'h018C: mux_lbus_do = blk_dout_reg[31:16];
        16'h018E: mux_lbus_do = blk_dout_reg[15:0];
        16'hFFFC: mux_lbus_do = 16'h4702;
        default:  mux_lbus_do = 16'h0000;
      endcase
   endfunction
   
endmodule // LBUS_IF