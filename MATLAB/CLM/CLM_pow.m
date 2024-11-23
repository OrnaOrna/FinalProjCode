function out = CLM_pow(t,m,q,P)
% Calculate t^(2^m) explicitly
sqr = flip(t);
for i=1:m
    sqr = conv(sqr,sqr);
end
sqr = flip(sqr);
% Perform CLM modulo PQ reduction
out = CLM_modPQ_reduc(sqr,q,P);
end