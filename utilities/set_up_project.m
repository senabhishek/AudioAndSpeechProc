function set_up_project()
% Set up the environment for this project. It should be set to
% "Run at Start Up".

%   Copyright 2011 The MathWorks, Inc.

% Use the Simulink Project API to get the current project:
p = Simulink.ModelManagement.Project.CurrentProject;

% Get the project root folder:
projectRoot = p.getRootFolder;

% Set the location where generated code and other temporary files are
% created (slprj) to be the "work" folder of the current project:
myCacheFolder = fullfile(projectRoot, 'work');
if ~exist(myCacheFolder, 'dir')
    mkdir(myCacheFolder)
end

% Set the path for this project:
folders = project_paths();
for jj=1:numel(folders)
    addpath( fullfile(projectRoot, folders{jj}) );
end

Simulink.fileGenControl('set', 'CacheFolder', myCacheFolder, ...
   'CodeGenFolder', myCacheFolder);


