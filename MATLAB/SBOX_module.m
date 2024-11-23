function sbox_out = SBOX_module(x_in,r,P,Q,fd)
% Full RAMBAM S-box module as described in the paper
warning('off', 'all');
d = floor(log2(Q));

T2 = pow_module(x_in, 1, P, Q);
% write_to_file(fd,T2,"T2")
t2 = mulAdd_module(T2, r(1,:), P, d);
% write_to_file(fd,t2,"t2")
T3 = Mul_module(x_in, t2, P, Q);
% write_to_file(fd,T3,"T3")
t3 = mulAdd_module(T3, r(2,:), P, d);
% write_to_file(fd,t3,"t3")
T12 = pow_module(t3, 2, P, Q);
% write_to_file(fd,T12,"T12")
t12 = mulAdd_module(T12, r(3,:), P, d);
% write_to_file(fd,t12,"t12")
T14 = Mul_module(t12, t2, P, Q);
% write_to_file(fd,T14,"T14")
T15 = Mul_module(t12, t3, P, Q);
% write_to_file(fd,T15,"T15")
t14 = mulAdd_module(T14, r(4,:), P, d);
% write_to_file(fd,t14,"t14")
t15 = mulAdd_module(T15, r(5,:), P, d);
% write_to_file(fd,t15,"t15")
T240 = pow_module(t15, 4, P, Q);
% write_to_file(fd,T240,"T240")
t240 = mulAdd_module(T240, r(6,:), P, d);
% write_to_file(fd,t240,"t240")
T254 = Mul_module(t240, t14, P, Q);
% write_to_file(fd,T254,"T254")
t254 = mulAdd_module(T254, r(7,:), P, d);
% write_to_file(fd,t254,"t254")
sbox_out = affineTransformation_module(t254, P, Q);
% write_to_file(fd,sbox_out,"sbox_out");


end