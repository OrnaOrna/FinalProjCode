function mat = mulL2(PQ, R2L)
% Creates transformation matrix for the linear operator of multiplying by x
% modulo PQ(x). The 2nd row of the isomorphism represents x in F_P
PQ_bits = (dec2bin(PQ) == '1');
m = length(PQ_bits);
mat = zeros(m-1,m-1);
for i=1:(m-1)
    [~, temp] = deconv([zeros(1,m-2-i) flip(R2L) zeros(1,i-1)], PQ_bits);
    mat(i,:) = flip(mod(temp(end-m+2:end), 2));
end
end