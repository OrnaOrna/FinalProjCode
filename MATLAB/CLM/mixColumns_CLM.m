function out = mixColumns_CLM(in,r,P,d)
state_mat = zeros(4,4,8+d);
new_state_mat = zeros(4,4,8+d);
% Convert to state matrix for convinience
byte_num = 1;
for j=1:4
    for i=1:4
        state_mat(i, j, :) = in(byte_num, :);
        byte_num = byte_num + 1;
    end
end

% Multiply each column by the mixColumns matrix seperately 
L = isomorphism(P);
GF_P02 = L(2, :);  % Matrix representing the linear operation of multiplying by x in the field
for i=1:4
    for j=1:4
        new_state_mat(i,j,:) = mod(CLM_mul(squeeze(state_mat(i,j,:)+state_mat(mod(i,4)+1,j,:))',GF_P02,r(4*(i-1)+j,:),P) + squeeze(state_mat(mod(i,4)+1,j,:) + state_mat(mod(i+1,4)+1,j,:) + state_mat(mod(i+2,4)+1,j,:))',2); 
    end
end

% Convert back
out = zeros(16,8+d);
byte_num = 1;
for j=1:4
    for i=1:4
        out(byte_num, :) = new_state_mat(i, j, :);
        byte_num = byte_num + 1;
    end
end
end