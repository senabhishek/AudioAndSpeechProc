clc;
close all;

% Load the model if not already open
mopen = bdIsLoaded('offlineProcessing'); % simulink_model_name
if (~mopen)
    disp('Loading model...');
    load_system('offlineProcessing');  % simulink_model_name
    disp('... done.');
    disp(' ');
end
disp('=====================================================================');

%% Set up model

in = input('MS or SPP? [1/0]: ');
if (in == 1)
    % Set switch
    set_param('offlineProcessing/MS_SPP','sw','1');       
else
    % Set switch
    set_param('offlineProcessing/MS_SPP','sw','0');
end

disp('=====================================================================');

%% Simulate the model

disp(' ');
disp('Simulation running...');
% Run the model
sim('offlineProcessing');                     % simulink_model_name
disp('offlineProcessing done.');

disp(' ');
disp('Results');

