function out = pow_module(t,m,P,Q)
% Performs t^(2^m) mod PQ(x)
pow_mat = my_pow(m, P, Q);
out = mod(t*pow_mat,2);
end