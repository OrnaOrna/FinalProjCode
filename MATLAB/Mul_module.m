function out = Mul_module(in1,in2,P,Q)
% Performs polynomial multplication modulo P(x)Q(x) 
P_bits = dec2bin(P)=='1';
Q_bits = dec2bin(Q)=='1';
temp = mulmod(flip(in1),flip(in2),mod(conv(P_bits,Q_bits),2));
temp = flip(temp);
out = temp(1:(length(Q_bits)+length(P_bits)-2));
end