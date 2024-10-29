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

`define P 9'b110101001
`define d 4
`define Q 5'b10001

//================================================ AES_Composite_enc
module AES_Composite_enc
  (Kin, Din, Dout, Krdy, Drdy, Kvld, Dvld, EN, BSY, CLK, RSTn);

   //------------------------------------------------
   input  [127:0] Kin;  // Key input
   input  [495:0] Din;  // Data input
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
   
   reg [127:0]    dat_compute, key_compute, Dout;
   reg [`d-1:0]   r_compute[0:22];
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
    
 
//    rambam_sbox #(.d(`d), .P(`P), .Q(`Q)) sbox (.plaintext(xored[127:120-`d]), .out(dat_out[127:120-`d]), .r(r_compute[0:6]));
    //rambam_sbox_storage #(.d(`d), .P(`P), .Q(`Q)) sbox(.clk(CLK), .rst(rst), .plaintext(xored[127:120-`d]), .out(dat_out[127:120-`d]), .r(r_compute[0:6]));
    rambam_aes_multiple_sbox rambam(.clk(CLK), .rst(rst), .plaintext(dat_compute), .key(key_compute), .random_vect(r_compute), .ciphertext(dat_out), .drdy_i(state), .drdy_o(rambam_drdy_o));
//   KeyExpantion keyexpantion 
//     (.kin(rkey), .kout(rkey_next), .rcon(rcon));
   
//   always @(posedge CLK or posedge rst) begin
//      if (rst)             rnd <= 10'b0000_0000_01;
//      else if (EN) begin
//         if (Drdy)         rnd <= {rnd[8:0], rnd[9]};
//         else if (~rnd[0]) rnd <= {rnd[8:0], rnd[9]};
//      end
//   end
   
//   always @(posedge CLK or posedge rst) begin
//      if (rst)     sel <= 0;
//      else if (EN) sel <= rnd[9];
//   end
   
//   always @(posedge CLK or posedge rst) begin
//      if (rst)                 dat <= 128'h0;
//      else if (EN) begin
//         if (Drdy)             dat <= Din ^ key;
//         else if (~rnd[0]|sel) dat <= dat_next;
//      end
//   end

   
//   always @(posedge CLK or posedge rst) begin
//      if (rst)     key <= 128'h0;
//      else if (EN)
//        if (Krdy)  key <= Kin;
//   end

//   always @(posedge CLK or posedge rst) begin
//      if (rst)         rkey <= 128'h0;
//      else if (EN) begin
//         if (Krdy)   rkey <= Kin;
//         else if (rnd[0]) rkey <= key;
//         else             rkey <= rkey_next;
//      end
//   end
   
//   always @(posedge CLK or posedge rst) begin
//     if (rst)          rcon <= 8'h01;
//     else if (EN) begin
//        if (Drdy)    rcon <= 8'h01;
//        else if (~rnd[0]) rcon <= xtime(rcon);
//     end
//   end
   
//   function [7:0] xtime;
//      input [7:0] x;
//      xtime = (x[7]==1'b0)? {x[6:0],1'b0} : {x[6:0],1'b0} ^ 8'h1B;
//   endfunction
endmodule // AES_Composite_enc



////================================================ KeyExpantion
//module KeyExpantion (kin, kout, rcon);

//   //------------------------------------------------
//   input [127:0]  kin;
//   output [127:0] kout;
//   input [7:0] 	  rcon;

//   //------------------------------------------------
//   wire [31:0]    ws, wr, w0, w1, w2, w3;

//   //------------------------------------------------
//   SubBytes SB0 ({kin[23:16], kin[15:8], kin[7:0], kin[31:24]}, ws);
//   assign wr = {(ws[31:24] ^ rcon), ws[23:0]};

//   assign w0 = wr ^ kin[127:96];
//   assign w1 = w0 ^ kin[95:64];
//   assign w2 = w1 ^ kin[63:32];
//   assign w3 = w2 ^ kin[31:0];

//   assign kout = {w0, w1, w2, w3};

//endmodule // KeyExpantion



////================================================ AES_Core
//module AES_Core (din, dout, kin, sel);

//   //------------------------------------------------
//   input  [127:0] din, kin;
//   input          sel;
//   output [127:0] dout;
   
//   //------------------------------------------------
//   wire [31:0] st0, st1, st2, st3, // state
//               sb0, sb1, sb2, sb3, // SubBytes
//               sr0, sr1, sr2, sr3, // ShiftRows
//               sc0, sc1, sc2, sc3, // MixColumns
//               sk0, sk1, sk2, sk3; // AddRoundKey

//   //------------------------------------------------
//   // din -> state
//   assign st0 = din[127:96];
//   assign st1 = din[ 95:64];
//   assign st2 = din[ 63:32];
//   assign st3 = din[ 31: 0];

//   // SubBytes
//   SubBytes SB0 (st0, sb0);
//   SubBytes SB1 (st1, sb1);
//   SubBytes SB2 (st2, sb2);
//   SubBytes SB3 (st3, sb3);

//   // ShiftRows
//   assign sr0 = {sb0[31:24], sb1[23:16], sb2[15: 8], sb3[ 7: 0]};
//   assign sr1 = {sb1[31:24], sb2[23:16], sb3[15: 8], sb0[ 7: 0]};
//   assign sr2 = {sb2[31:24], sb3[23:16], sb0[15: 8], sb1[ 7: 0]};
//   assign sr3 = {sb3[31:24], sb0[23:16], sb1[15: 8], sb2[ 7: 0]};

//   // MixColumns
//   MixColumns MC0 (sr0, sc0);
//   MixColumns MC1 (sr1, sc1);
//   MixColumns MC2 (sr2, sc2);
//   MixColumns MC3 (sr3, sc3);

//   // AddRoundKey
//   assign sk0 = (sel) ? sr0 ^ kin[127:96] : sc0 ^ kin[127:96];
//   assign sk1 = (sel) ? sr1 ^ kin[ 95:64] : sc1 ^ kin[ 95:64];
//   assign sk2 = (sel) ? sr2 ^ kin[ 63:32] : sc2 ^ kin[ 63:32];
//   assign sk3 = (sel) ? sr3 ^ kin[ 31: 0] : sc3 ^ kin[ 31: 0];

//   // state -> dout
//   assign dout = {sk0, sk1, sk2, sk3};
//endmodule // AES_Core



////================================================ MixColumns
//module MixColumns(x, y);

//   //------------------------------------------------
//   input  [31:0]  x;
//   output [31:0]  y;

//   //------------------------------------------------
//   wire [7:0]    a0, a1, a2, a3;
//   wire [7:0]    b0, b1, b2, b3;

//   assign a0 = x[31:24];
//   assign a1 = x[23:16];
//   assign a2 = x[15: 8];
//   assign a3 = x[ 7: 0];

//   assign b0 = xtime(a0);
//   assign b1 = xtime(a1);
//   assign b2 = xtime(a2);
//   assign b3 = xtime(a3);

//   assign y[31:24] =    b0 ^ a1^b1 ^ a2    ^ a3;
//   assign y[23:16] = a0        ^b1 ^ a2^b2 ^ a3;
//   assign y[15: 8] = a0    ^ a1        ^b2 ^ a3^b3;
//   assign y[ 7: 0] = a0^b0 ^ a1    ^ a2        ^b3;
  
//   function [7:0] xtime;
//      input [7:0] x;
//      xtime = (x[7]==1'b0)? {x[6:0],1'b0} : {x[6:0],1'b0} ^ 8'h1B;
//   endfunction
   
//endmodule // MixColumns

   

////================================================ SubBytes
//module SubBytes (x, y);

//   //------------------------------------------------
//   input  [31:0] x;
//   output [31:0] y;

//   //------------------------------------------------
//   wire [31:0] 	s;

//   //------------------------------------------------
//   GF_MULINV_8 u3 (.x(x[31:24]), .y(s[31:24]));
//   GF_MULINV_8 u2 (.x(x[23:16]), .y(s[23:16]));
//   GF_MULINV_8 u1 (.x(x[15: 8]), .y(s[15: 8]));
//   GF_MULINV_8 u0 (.x(x[ 7: 0]), .y(s[ 7: 0]));
 
//   assign y = {mat_at(s[31:24]), mat_at(s[23:16]), 
//	       mat_at(s[15: 8]), mat_at(s[ 7: 0])};
    
//   //------------------------------------------------ Affine matrix
//   function [7:0] mat_at;
//      input [7:0] x;
//      begin
//	 mat_at[0] = ~(x[7] ^ x[6] ^ x[5] ^ x[4] ^ x[0]);
//	 mat_at[1] = ~(x[7] ^ x[6] ^ x[5] ^ x[1] ^ x[0]);
//	 mat_at[2] =   x[7] ^ x[6] ^ x[2] ^ x[1] ^ x[0];
//	 mat_at[3] =   x[7] ^ x[3] ^ x[2] ^ x[1] ^ x[0];
//	 mat_at[4] =   x[4] ^ x[3] ^ x[2] ^ x[1] ^ x[0];
//	 mat_at[5] = ~(x[5] ^ x[4] ^ x[3] ^ x[2] ^ x[1]);
//	 mat_at[6] = ~(x[6] ^ x[5] ^ x[4] ^ x[3] ^ x[2]);
//	 mat_at[7] =   x[7] ^ x[6] ^ x[5] ^ x[4] ^ x[3];
//      end
//   endfunction
//endmodule // SubBytes



///*-------------------------------------------------------------------------
// Thanks for great works of pioneers!
// This code is developed by refering following papers.
//  [1] A.Satoh, S.Morioka, K.Takano, S.Munetoh, "A compact Rijndael Hardware Architecture with S-box Optimization," ASIACRYPT 2001, LNCS 2248, pp.239-254, 2001.
//  [2] D. Canright, "A Very Compact Rijndael S-box," 2005.
//  [3] Edwin NC Mui, "Practical Implementation of Rijndael S-Box Using Combinational Logic," 2007.
 
// Following paper may help to find different polynomials.
//  [1] N.Mentens, L.Batina, B.Preneel, I.Vervauwhede, "A Systematic Evaluation of Compact Hardware Implementations for the Rijndael S-Box," LNCS 3376, pp.323-333, 2005.
//-------------------------------------------------------------------------*/

////================================================ GF_MULINV_8
//module GF_MULINV_8 (x, y);

//   //------------------------------------------------
//   input  [7:0] x;
//   output [7:0] y;
   
//   //------------------------------------------------
//   wire [7:0] 	xt, yt;
//   wire [3:0] 	g1, g0, g1_g0, p, pi;
   
//   //------------------------------------------------
//   // GF(2^8) -> GF(2^2^2) transform
//   assign xt = mat_x(x);

//   // Multipricative inversion in GF(2^2^2)
//   assign {g1, g0} = xt;
//   assign g1_g0    = g1 ^ g0;

//   assign p = gf_mul4_lambda(gf_sq4(g1)) ^ gf_mul4(g1_g0, g0);
//   GF_MULINV_4 u0 (p, pi);
   
//   assign yt[7:4]  = gf_mul4(g1, pi);
//   assign yt[3:0]  = gf_mul4(g1_g0, pi);
   
//   // GF(2^2^2) -> GF(2^8) inverse transform
//   assign y = mat_xi(yt);
	     
//   //------------------------------------------------ 
//   // Isomorphism matrix (lambda = 4'b1100, phi = 2'b10)
//   function [7:0] mat_x;
//      input [7:0] x;
//      begin
//	 mat_x[7] =  x[7]        ^ x[5];
//	 mat_x[6] =  x[7] ^ x[6]        ^ x[4] ^ x[3] ^ x[2] ^ x[1];
//	 mat_x[5] =  x[7]        ^ x[5]        ^ x[3] ^ x[2];
//	 mat_x[4] =  x[7]        ^ x[5]        ^ x[3] ^ x[2] ^ x[1];
//	 mat_x[3] =  x[7] ^ x[6]                      ^ x[2] ^ x[1];
//	 mat_x[2] =  x[7]               ^ x[4] ^ x[3] ^ x[2] ^ x[1];
//	 mat_x[1] =         x[6]        ^ x[4]               ^ x[1];
//	 mat_x[0] =         x[6]                             ^ x[1] ^ x[0];
//      end
//   endfunction
      
//   function [7:0] mat_xi;
//      input [7:0] x;
//      begin
//	 mat_xi[7] =  x[7] ^ x[6] ^ x[5]                      ^ x[1];
//	 mat_xi[6] =         x[6]                      ^ x[2];
//	 mat_xi[5] =         x[6] ^ x[5]                      ^ x[1];
//	 mat_xi[4] =         x[6] ^ x[5] ^ x[4]        ^ x[2] ^ x[1];
//	 mat_xi[3] =                x[5] ^ x[4] ^ x[3] ^ x[2] ^ x[1];
//	 mat_xi[2] =  x[7]               ^ x[4] ^ x[3] ^ x[2] ^ x[1];
//	 mat_xi[1] =                x[5] ^ x[4];
//	 mat_xi[0] =         x[6] ^ x[5] ^ x[4]        ^ x[2]        ^ x[0];
//      end
//   endfunction
   
//   //------------------------------------------------ Square 
//   function [3:0] gf_sq4;
//      input [3:0] x;
//      begin
//	 gf_sq4[0] = x[3] ^ x[1] ^ x[0];
//	 gf_sq4[1] = x[2] ^ x[1];
//	 gf_sq4[2] = x[3] ^ x[2];
//	 gf_sq4[3] = x[3];      
//      end
//   endfunction // gf_sq4

//   //------------------------------------------------ Multiply
//   function [3:0] gf_mul4;
//      input [3:0] x, y;
//      begin
//	 gf_mul4[3] = x[3]&y[3] ^ x[3]&y[1] ^ x[1]&y[3] ^ 
//		      x[2]&y[3] ^ x[2]&y[1] ^ x[0]&y[3] ^
//		      x[3]&y[2] ^ x[3]&y[0] ^ x[1]&y[2];
	 
//	 gf_mul4[2] = x[3]&y[3] ^ x[3]&y[1] ^ x[1]&y[3] ^
//		      x[2]&y[2] ^ x[2]&y[0] ^ x[0]&y[2];
	 
//	 gf_mul4[1] = x[2]&y[3] ^ x[3]&y[2] ^ x[2]&y[2]^
//		      x[1]&y[1] ^ x[0]&y[1] ^ x[1]&y[0];
	 
//	 gf_mul4[0] = x[3]&y[3] ^ x[2]&y[3] ^ x[3]&y[2]^
//		      x[1]&y[1] ^ x[0]&y[0];   
//      end
//   endfunction

//   // lambda = 4'b1100
//   function [3:0] gf_mul4_lambda;
//      input [3:0] x;
//      begin
//	 gf_mul4_lambda[3] = x[2] ^ x[0];
//	 gf_mul4_lambda[2] = x[3] ^ x[2] ^ x[1] ^ x[0];
//	 gf_mul4_lambda[1] = x[3];
//	 gf_mul4_lambda[0] = x[2];
//      end
//   endfunction

//endmodule // GF_MULINV_8



////================================================ GF_MULINV_4
//module GF_MULINV_4 (x, y);

//   //------------------------------------------------
//   input  [3:0] x;
//   output [3:0] y;
   
//   //------------------------------------------------
//   wire [1:0] 	g1, g0, g1_g0, p, pi;

   
//   //------------------------------------------------
//   // Multipricative inversion in GF(2^2)
//   assign {g1, g0} = x;
//   assign g1_g0    = g1 ^ g0;

//   assign p        = gf_mul2_phi(gf_sq2(g1)) ^ gf_mul2(g1_g0, g0);
//   assign pi       = gf_inv2(p);

//   assign y[3:2]   = gf_mul2(g1, pi);
//   assign y[1:0]   = gf_mul2(g1_g0, pi);
   
//   //------------------------------------------------ Square
//   function [1:0] gf_sq2;
//      input [1:0] x;
//      begin
//	 gf_sq2[1] = x[1];
//	 gf_sq2[0] = x[1] ^ x[0];
//      end
//   endfunction // case

//   //------------------------------------------------ Multiply
//   function [1:0] gf_mul2;
//      input [1:0] x, y;
//      begin
//	 gf_mul2[1] = x[1]&y[1] ^ x[0]&y[1] ^ x[1]&y[0];
//	 gf_mul2[0] = x[1]&y[1] ^ x[0]&y[0];
//      end
//   endfunction // case

//   // phi = 2'b10
//   function [1:0] gf_mul2_phi;
//      input [1:0] x;
//      begin
//	 gf_mul2_phi[1] = x[1] ^ x[0];
//	 gf_mul2_phi[0] = x[1];
//      end
//   endfunction // case

//   //------------------------------------------------ Multiplicative inversion
//   function [1:0] gf_inv2;
//      input [1:0] x;
//      begin
//	 gf_inv2[1] = x[1];
//	 gf_inv2[0] = x[1] ^ x[0];
//      end
//   endfunction // case
      
//endmodule // GF_MULINV4
