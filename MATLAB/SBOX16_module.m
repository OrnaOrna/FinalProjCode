function out = SBOX16_module(in,r,P,Q,d)
% Performs 16 S-box operations and refreshing the randomness 
out = zeros(size(in));
for i=1:16
    out(i,:) = SBOX_module(in(i,:), r, P, Q, '');
    temp = r(1,:);
    for j=1:6
        r(j,:) = r(j+1,:);
    end
    r(7,:) = temp;
end
end