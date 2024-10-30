function p1p2 = mulmod(P1, P2, P)
% Multiply 2 polynomials modulo different polynomial
[~, temp] = deconv(conv(P1,P2), P);
p1p2 = mod(temp, 2);
end