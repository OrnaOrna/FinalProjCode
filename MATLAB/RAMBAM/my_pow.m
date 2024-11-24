function power_matrix = my_pow(m, P, Q)
% Creates transformation matrix for T(p(x))=p(x)^(2^m) mod PQ(x)
P_bits = dec2bin(P) == '1';
Q_bits = dec2bin(Q) == '1';
PQ_bits = mod(conv(P_bits,Q_bits),2);
x_2m = [1 0];
for i=1:m
    x_2m = mulmod(x_2m, x_2m, PQ_bits);
end
power_matrix = zeros(length(PQ_bits)-1);
power_matrix(1, length(PQ_bits)-1) = 1;
for i=1:(length(PQ_bits)-2)
    temp = mulmod(power_matrix(i,:),x_2m,PQ_bits);
    power_matrix(i+1,:) = temp(length(temp)-length(PQ_bits)+2:end);
end
power_matrix = flip(power_matrix, 2);
end