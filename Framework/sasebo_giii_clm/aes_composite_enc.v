/*-------------------------------------------------------------------------
 AES (128-bit, composite field S-box, encryption)

 File name   : aes_composite_enc.v
 Version     : 1.0
 Created     : JUN/12/2012
 Last update : JUN/22/2012
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
//================================================ AES_Composite_enc
import types::*;

module AES_Composite_enc
  (Kin, Din, Dout, Krdy, Drdy, Kvld, Dvld, EN, BSY, CLK, RSTn);

   //------------------------------------------------
   input  [127:0] Kin;  // Key input
   input  [511:0] Din;  // Data input
   output [127:0] Dout; // Data output
   input          Krdy; // Key input ready
   input          Drdy; // Data input ready
   output         Kvld; // Data output valid
   output         Dvld; // Data output valid

   input          EN;   // AES circuit enable
   output         BSY;  // Busy signal
   input          CLK;  // System clock
   input          RSTn; // Reset (Low active)

   //------------------------------------------------
   
   logic [127:0]    dat_compute, key_compute, Dout;
   logic [0:4] p_compute;
   reg [0:22][d-1:0] r_compute;
   reg state;
   reg [9:0] sbox_ctr;
   
   wire [127:0]   dat_out;
//   reg [9:0]      rnd;  
//   reg [7:0]      rcon; 
//   reg            sel;  // Indicate final round
   reg            Dvld, Kvld, BSY;
   wire           rst;
   logic rambam_drdy_o;
   
   //------------------------------------------------
   assign rst = ~RSTn;
   assign BSY = 0;
  

//   always @(posedge CLK or posedge rst) begin
//      if (rst)     Dvld <= 0;
//      else if (EN) Dvld <= sel;
//   end

   always @(posedge CLK or posedge rst) begin
      if (rst) Kvld <= 0;
      else if (EN) Kvld <= Krdy;
   end

//   always @(posedge CLK or posedge rst) begin
//      if (rst) BSY <= 0;
//      else if (EN) BSY <= Drdy | |rnd[9:1] | sel;
   always @(posedge CLK or posedge rst) begin
        if (rst) begin
            Dvld        <= 1'b0;
            state       <= 1'b0;
            dat_compute <= 128'b0;
            key_compute <= 128'b0;
            r_compute   <= '{default:0}; 
            r_compute   <= '{default:0}; 
            Dout <= '{default:0};         
        end
        else if(EN) begin  
                   
            if (Drdy) begin
                state <= 1'b1;
                p_compute <= Din[500:496];
                dat_compute <= Din[127:0];
                
                r_compute[0] <= Din[495:496-`d];
                r_compute[1] <= Din[479:480-`d];
                r_compute[2] <= Din[463:464-`d];
                r_compute[3] <= Din[447:448-`d];
                r_compute[4] <= Din[431:432-`d];
                r_compute[5] <= Din[415:416-`d];
                r_compute[6] <= Din[399:400-`d];
                r_compute[7] <= Din[383:384-`d];
                r_compute[8] <= Din[367:368-`d];
                r_compute[9] <= Din[351:352-`d];
                r_compute[10] <= Din[335:336-`d];
                r_compute[11] <= Din[319:320-`d];
                r_compute[12] <= Din[303:304-`d];
                r_compute[13] <= Din[287:288-`d];
                r_compute[14] <= Din[271:272-`d];
                r_compute[15] <= Din[255:256-`d];
                r_compute[16] <= Din[239:240-`d];
                r_compute[17] <= Din[223:224-`d];
                r_compute[18] <= Din[207:208-`d];
                r_compute[19] <= Din[191:192-`d];
                r_compute[20] <= Din[175:176-`d];
                r_compute[21] <= Din[159:160-`d];
                r_compute[22] <= Din[143:144-`d];
    
                key_compute <= Kin;
            end else begin
                if (state) begin
                    if (rambam_drdy_o) begin
                        state <= 1'b0;
                        Dvld <= 1'b1;
                        Dout <= dat_out;
                    end else begin
                        Dvld <= 1'b0;
                    end
                
                end else begin
                    Dvld <= 1'b0;
                end
             end
        end 
    end
    
    clm_inouts_if clm_inouts();
    assign clm_inouts.clk = CLK;
    assign clm_inouts.rst = rst;
    assign clm_inouts.plaintext = dat_compute;
    assign clm_inouts.key = key_compute;
    assign clm_inouts.ciphertext = dat_out;
    assign clm_inouts.drdy_i = state;
    assign rambam_drdy_o = clm_inouts.drdy_o;

    
 
//    rambam_sbox #(.d(`d), .P(`P), .Q(`Q)) sbox (.plaintext(xored[127:120-`d]), .out(dat_out[127:120-`d]), .r(r_compute[0:6]));
    //rambam_sbox_storage #(.d(`d), .P(`P), .Q(`Q)) sbox(.clk(CLK), .rst(rst), .plaintext(xored[127:120-`d]), .out(dat_out[127:120-`d]), .r(r_compute[0:6]));
    clm_aes_multiple_sbox_limited_p clm(.inouts(clm_inouts.basic), .random_vect(r_compute), .p_det(p_compute));
endmodule // AES_Composite_enc