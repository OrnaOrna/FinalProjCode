function out = affineTransformation_module(in,P,Q)
% Module apply the affine transformation on the input 
[W, w] = affineTransformation(P,Q);
out = mod(in*W + w,2);
end