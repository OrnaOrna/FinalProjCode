function out = CLM_pow(t,m,q,P)
% Calculate t^(2^m) explicitly
for i=1:m
    sqr = flip(t);
    sqr = conv(sqr,sqr);
    sqr = flip(sqr);
    out = CLM_modPQ_reduc(sqr,q,P);
end
% Perform CLM modulo PQ reduction
end