% Yair it is very easy, just take the inputs and write them here
P1 = strsplit('12 34', ' ');
P2 = strsplit('80 00', ' ');
POLY_NUM = 11;

% Very complicated stuff you dont have to understand
all_irreduc_pol = [283, 285, 299, 301, 313, 319, 333, 351, 355, 357, 361, 369, 375, 379, 391, 395, 397, 415, 419, 425, 433, 445, 451, 463, 471, 477, 487, 499, 501, 505];
p1_arr = [pad(dec2bin(hex2dec(P1(1))), 8, 'left', '0') pad(dec2bin(hex2dec(P1(2))), 8, 'left', '0')]=='1';
p2_arr = [pad(dec2bin(hex2dec(P2(1))), 8, 'left', '0') pad(dec2bin(hex2dec(P2(2))), 8, 'left', '0')]=='1';

P = all_irreduc_pol(POLY_NUM);
Q = 1;
% Performs polynomial multplication modulo P(x)Q(x) 
P_bits = dec2bin(P)=='1';
Q_bits = dec2bin(Q)=='1';
res = flip(mulmod(flip(p1_arr),flip(p2_arr),P_bits));
res(1:9)
