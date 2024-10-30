function out = modP_module(in,P,d)
% Performs mod P(x) using a matrix
mat = modPmat(P,d);
m = length((dec2bin(P)=='1'));
Mat = [eye(m-1); mat];  % Upper part is unit because x^k mod P(x) = x^k when k<m
out = mod([in zeros(1,m+d-1-length(in))]*Mat, 2);  % Multiply the polynomial by the mod P matrix
end