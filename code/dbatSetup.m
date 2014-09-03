% $Id$

% Get dir of executing (i.e. this!) file.
baseDir=fileparts(mfilename('fullpath'));

% Add selected subdirectories.
addpath(fullfile(baseDir,'plotting'),'-end')
addpath(fullfile(baseDir,'file'),'-end')
addpath(fullfile(baseDir,'misc'),'-end')
addpath(fullfile(baseDir,'bundle'),'-end')
addpath(fullfile(baseDir,'bundle','cammodel'),'-end')
addpath(fullfile(baseDir,'bundle','lsa'),'-end')
addpath(fullfile(baseDir,'photogrammetry'),'-end')
addpath(fullfile(baseDir,'demo'),'-end')
addpath(baseDir,'-end')

fprintf('You can now access DBAT v%s from everywhere.\n',dbatversion)

clear baseDir
