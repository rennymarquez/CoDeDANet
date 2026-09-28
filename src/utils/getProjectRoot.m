function root = getProjectRoot()
%GETPROJECTROOT Absolute path to the CoDeDANet repository root.
%   ROOT = GETPROJECTROOT() returns the folder that contains setup.m,
%   src/, legacy/ and datasets/, regardless of the machine or operating
%   system the code is running on.
%
%   It works by locating this very file (which always lives at
%   <root>/src/utils/getProjectRoot.m) and walking up two levels.
%   This replaces the old hardcoded paths such as
%   'C:\Users\renni\Dropbox\McGill work\CodeRenny' or
%   '/mnt/sda6/Dropbox/McGill work/CodeRenny' that were scattered
%   across the original scripts.
%
%   Make sure setup.m has been run at least once per MATLAB session so
%   that this function is on the path.

    utilsDir = fileparts(mfilename('fullpath'));   % .../src/utils
    srcDir   = fileparts(utilsDir);                % .../src
    root     = fileparts(srcDir);                  % repo root
end
