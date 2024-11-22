function out = keyExpansion_CLM(in,r,P,rnd,d)
% Recieves the key from the previous round and the round number and apply 
% the modified key expansion to produce the current key 
state_mat = zeros(4,4,8+d);
new_state_mat = zeros(4,4,8+d);
% State matrix after shifting by 1
byte_num = 1;
for j=1:4
    for i=1:4
        state_mat(i, j, :) = in(byte_num, :);
        byte_num = byte_num + 1;
    end
end
% Fix the dimensions
w0 = squeeze(state_mat(:,1,:));
w1 = squeeze(state_mat(:,2,:));
w2 = squeeze(state_mat(:,3,:));
w3 = squeeze(state_mat(:,4,:));

% Key expansion
w0 = mod(w0 + g_ke_CLM(w3,r,P,rnd), 2);
w1 = mod(w0 + w1, 2);
w2 = mod(w1 + w2, 2);
w3 = mod(w2 + w3, 2);

new_state_mat(:,1,:) = w0;
new_state_mat(:,2,:) = w1;
new_state_mat(:,3,:) = w2;
new_state_mat(:,4,:) = w3;

% Convert back from state matrix
out = zeros(16,8+d);
byte_num = 1;
for j=1:4
    for i=1:4
        out(byte_num, :) = new_state_mat(i, j, :);
        byte_num = byte_num + 1;
    end
end
end