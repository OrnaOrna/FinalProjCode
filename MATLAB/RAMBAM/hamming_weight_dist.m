m = 8;  % 128-bit AES
all_prim_pol = primpoly(m,'all','nodisplay');  
P = hex2dec('163');  % Chooses primitive polynomial for P
Q = hex2dec('17');
d = floor(log2(Q));  % The degree of the plolynomial represented by Q
L = isomorphism(P);
L_inv = inverse_over_F2(L);

histogram_b = [];
hw_count = zeros(1 ,8+d);
hw_count_count = zeros(1 ,9);
for j=0:(2^m-1)
    for i=0:(2^d-1)
        in = j;%randi([0, (2^m-1)]);
        bit8_input = flip(dec2bin(in)=='1');
        bit8_input = [bit8_input zeros(1, m - length(bit8_input))];
        
        r = dec2bin(i)=='1';
        x_in = mulAdd_module(mod(bit8_input*L,2),[r zeros(1, d - length(r))],P,d);
        T2 = pow_module(x_in, 1, P, Q);
        histogram_b = [histogram_b sum(T2 == 1)];
        %hw_count(sum(T2 == 1)+1) = hw_count(sum(T2 == 1)+1) + 1;
        %hw_count((sum(bit8_input == 1)+1)) = hw_count((sum(bit8_input == 1)+1)) + 1;
        %hw_count_count((sum(bit8_input == 1)+1)) = hw_count((sum(bit8_input == 1)+1)) + sum(T2 == 1);
    end
end
%result = hw_count_count./hw_count;
%result(isnan(result)) = 0;
% result = hw_count;
% plot(0:1:(7+d), result, '-o')
histogram(histogram_b)
mean(histogram_b)
var(histogram_b)
