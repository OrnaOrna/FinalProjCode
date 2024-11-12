function write_to_file(fileID,binaryArray,name)
% Writes matrix/array to a Verilog defines file 
fprintf(fileID, '`define %s ', name);
if name=="d"
    disp(binaryArray)
    fprintf(fileID, '%d', binaryArray);
    fprintf(fileID, '\n');
    return
end
% Step 1: Flatten the matrix
linearArray = binaryArray(:)';
% Step 2: Convert the linear array to a string
binaryString = num2str(linearArray);
binaryString = strrep(binaryString, ' ', ''); % Remove spaces
fprintf(fileID, '%d''b%s', length(binaryString), binaryString);
fprintf(fileID, '\n');


end