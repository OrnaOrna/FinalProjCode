function out = g_ke(w,r,P,Q,rnd)
% Help function for the modified key expansion 
temp = w(1,:);
% Byte shifting 
for i=1:3
    w(i,:) = SBOX_module(w(i+1,:),r,P,Q,'');
end
w(4,:) = SBOX_module(temp,r,P,Q,'');
 
% Xoring with RCON 
L = isomorphism(P);
mulL2_mat = mulL2(P, L(2,:));
RC_1 = [1 zeros(1,7)];
RC_i = RC_1*mulL2_mat^(rnd-1);
w(1,1:8) = mod(w(1,1:8)+RC_i,2);
out=w;
end