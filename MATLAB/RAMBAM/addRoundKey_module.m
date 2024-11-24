function out = addRoundKey_module(x,k,d)
% Module receives plaintext and key and xor them 
[m,n] = size(x);
out = zeros(m,n);
for i=1:m
    out(i,:) = mod(x(i,:)+[k(i,:) zeros(1,length(x(i,:)) - length(k(i,:)))], 2); % Xoring (zero padding in case x & k are not the same size)
end
end