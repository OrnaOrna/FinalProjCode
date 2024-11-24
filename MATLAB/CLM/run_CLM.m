addpath(folder_path());
warning('off', 'all')
% Choose CLM parameters 
P = hex2dec('169');
d = 8;
% Choose plaintext and key (hexadecimal) 
key_str = strsplit('00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00', ' ');
pt_str = strsplit('00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 ff', ' ');

key_arr = zeros(16,8);
pt_arr = zeros(16,8);
for i=1:16
    key_arr(i,:) = flip(pad(dec2bin(hex2dec(key_str(i))), 8, 'left', '0')=='1');
    pt_arr(i,:) = flip(pad(dec2bin(hex2dec(pt_str(i))), 8, 'left', '0')=='1');
end

CLM_module(pt_arr, key_arr, randi([0 0], 23, d), P, d)