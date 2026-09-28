%SETUP Run this once per MATLAB session before using anything in this
%   repository. It adds all the code folders to the MATLAB path and
%   creates the working folders that the scripts expect to find next to
%   this file (datasets, cached results, exported images).
%
%   Usage:
%       >> setup
%
%   After this, run any script directly, e.g.:
%       >> codedanet   % the full CoDeDANet algorithm
%       >> swa         % SwA baseline
%       >> dwoa        % DwoA baseline

root = fileparts(mfilename('fullpath'));

addpath(genpath(fullfile(root,'src')));

% Folders the scripts read from / write to. They are not tracked in
% git (see .gitignore) so this creates them on first run.
requiredFolders = {
    'datasets'
    'CreateData'  % working folder codedanet.m/swa.m/dwoa.m cd into before running
    'Results'
};

for i = 1:numel(requiredFolders)
    folder = fullfile(root, requiredFolders{i});
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
end

%% Tensor Toolbox for MATLAB (Kolda & Bader) - required by codedanet.m and dwoa.m
% Not part of this repository. If it is not on the path, use a copy in
% third_party/, or offer to download release v3.1 (BSD 2-clause license).
if isempty(which('tensor')) || isempty(which('tenmat'))
    ttbRoot = fullfile(root,'third_party');
    found = dir(fullfile(ttbRoot,'tensor_toolbox*'));
    found = found([found.isdir]);
    if isempty(found)
        reply = input('Tensor Toolbox not found. Download v3.1 (about 2 MB) into third_party/? [y/N] ','s');
        if strcmpi(strtrim(reply),'y')
            try
                if ~exist(ttbRoot,'dir'), mkdir(ttbRoot); end
                zipFile = fullfile(ttbRoot,'tensor_toolbox-v3.1.zip');
                websave(zipFile,'https://github.com/sandialabs/tensor_toolbox/archive/refs/tags/v3.1.zip');
                unzip(zipFile,ttbRoot);
                delete(zipFile);
                found = dir(fullfile(ttbRoot,'tensor_toolbox*'));
                found = found([found.isdir]);
            catch err
                warning('CoDeDANet:ttbDownload', ...
                    'Automatic download failed (%s). Download Tensor Toolbox v3.1 manually and unzip it into third_party/.', err.message);
            end
        end
    end
    if ~isempty(found)
        addpath(genpath(fullfile(ttbRoot,found(1).name)));
    end
    if isempty(which('tensor'))
        warning('CoDeDANet:ttbMissing','Tensor Toolbox is still not on the path; codedanet.m and dwoa.m will fail on tensor().');
    else
        disp("Tensor Toolbox ready: " + string(which('tensor')))
    end
end
cd(root)
disp("CoDeDANet repo ready. Project root: " + string(root))
