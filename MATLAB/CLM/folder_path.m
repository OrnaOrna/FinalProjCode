function functionsFolder = folder_path(folder_name)
% Default folder is RAMBAM
if nargin < 1
    folder_name = 'RAMBAM'; 
end
currentFolder = fileparts(mfilename('fullpath'));
functionsFolder = fullfile(currentFolder, ['../' folder_name]);
end