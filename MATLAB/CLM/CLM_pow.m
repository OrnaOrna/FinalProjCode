function out = CLM_pow(t,m,q,P)
% Calculate t^(2^m) explicitly
out = t;
for i=1:m
    sqr = flip(out);
    sqr = mod(conv(sqr,sqr),2);
    sqr = flip(sqr);
    % Perform CLM modulo PQ reduction
    out = CLM_modPQ_reduc(sqr,q,P);
end
end