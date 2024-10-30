% This script is used to produce parameters to the CLM
m = 8;
d = 4;
syms x
all_irreduc_pol = [283, 285, 299, 301, 313, 319, 333, 351, 355, 357, 361, 369, 375, 379, 391, 395, 397, 415, 419, 425, 433, 445, 451, 463, 471, 477, 487, 499, 501, 505];

% Create files for parameters 
allP_file = fopen('allP.svh', 'w');
allL_file = fopen('allL.svh', 'w');
allLinv_file = fopen('allLinv.svh', 'w');
allW11_file = fopen('allW11.svh', 'w');
allW21_file = fopen('allW21.svh', 'w');
allw_file = fopen('allw.svh', 'w');

% Produce parameters and writing them to file
for i=1:length(all_irreduc_pol)
    P = all_irreduc_pol(i);
    L = isomorphism(P);
    L_inv = inverse_over_F2(L);
    [W11,W21,w] = affineTransformation_export(P,d);
    write_to_file(allP_file,flip(dec2bin(P)=='1'),"P"+i)
    write_to_file(allL_file,L',"L"+i)
    write_to_file(allLinv_file,L_inv',"Linv"+i)
    write_to_file(allW11_file,W11',"W11_"+i)
    write_to_file(allW21_file,W21',"W21_"+i)
    write_to_file(allw_file,w',"w"+i)
end
