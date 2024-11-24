function out = CLM_modPQ_reduc(w,q,P)
% Add the RAMBAM folder to path in order to use its functions 
addpath(folder_path());
% Parameters
m = floor(log2(P));
d = length(q);
l = length(w);
% Define the information bits of the code word
z = zeros(1, l-m);
z(d+1:end) = w(m+d+1:end);
z(1:d) = q(:);
% Create A matrix
right_cols = [eye(d); zeros(l-m-d, d)];
A = [generator_matrix(P,l-m) right_cols];
% Calculate output
out = mod(w(1:m+d)+z*A,2);
end