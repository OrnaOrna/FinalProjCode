function B = generator_matrix(P, d)
% Produce the generator matrix for the cyclic code created by P(x) with
% parameters [m+d,d] (m = deg[P(x)])
P_bits =  dec2bin(P) == '1';
r = length(P_bits) - 1;
B = zeros(d, r);
temp = [1 zeros(1, r-1)];
x = [1 0];
temp = mulmod(temp, x, P_bits);  % Calculates -x^(m+1) mod P(x)
for i=1:d
    temp = temp(2:end);
    B(i,:) = temp;  % Inserts the current result to the matrix 
    temp = mulmod(temp, x, P_bits);  % Calculates -x^(m+i+1) mod P(x)

end
B = flip(B, 2);
end