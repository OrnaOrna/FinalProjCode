function out = SBOX16_CLM(in,r,P)
% Performs 16 S-box operations and refreshing the randomness 
out = zeros(size(in));
for i=1:16
    out(i,:) = CLM_Sbox(in(i,:), r, P);
    % Refresh by shift
    temp = r(1,:);
    for j=1:6
        r(j,:) = r(j+1,:);
    end
    r(7,:) = temp;
end
end