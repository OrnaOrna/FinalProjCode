function out = mulAdd_module(t,r,P,d)
% Adds r(x)P(x) to the current polynomial (Refresh)
mulP = mulPmat(P,d);
out = mod([t zeros(1, floor(log2(P))+d-length(t))] + r*mulP,2);
end