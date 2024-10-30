function out = mixColumns_module(in,P,Q,d)
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
R_PQ02 = mulL2(mod(conv(dec2bin(P)=='1', dec2bin(Q)=='1'),2), L(2, :));  % Matrix representing the linear operation of multiplying by x in the field
for i=1:4
    for j=1:4
        new_state_mat(i,j,:) = mod(squeeze(state_mat(i,j,:))'*R_PQ02 + squeeze(state_mat(mod(i,4)+1,j,:))'*R_PQ02 + squeeze(state_mat(mod(i,4)+1,j,:) + state_mat(mod(i+1,4)+1,j,:) + state_mat(mod(i+2,4)+1,j,:))',2); 
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