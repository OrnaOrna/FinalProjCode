function L = isomorphism(P, root)
% The root number is a default variable 
if nargin == 1
    root = 1;
end
% Calculates isomorphism matrix from GF_P0 to GF_P
P0 = 'D8+D4+D3+D+1';
all_elements_p = gf(1:255, 8, P);  % Generate all elements of GF_P
all_minpol_p = minpol(all_elements_p');
x_p0 = gf(2, 8, P0);  % Element x in GF_P0
minpol_x_p0 = minpol(x_p0);  % Minimal polymial of x
possible_img = find(ismember(all_minpol_p.x,minpol_x_p0.x, 'rows'));  % Search for the minimal polynomial
L_x = all_elements_p(possible_img(root));  % We now know where x is sent to -> we can get L
L = L_x.^(0:7);  % The other rows are L(x)^2, L(x)^3, ...
L = (dec2bin(L.x)=='1');
L = flip(L,2);   % Flip L to fit to our convention (Left bit is the lowest power of the polynomial)
end