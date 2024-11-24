function out = shiftRows_module(in)
% Performs the original shift rows operation
out = zeros(size(in));
for i=0:3
    for j=0:3
        out(i+1+4*j,:) = in(mod(i+1+4*j+4*i,16)+(mod(i+1+4*j+4*i,16)==0)*16,:);
    end
end
end