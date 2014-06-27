clc;
close all;

% Load the model if not already open
mopen = bdIsLoaded('realTimeProcessing'); % simulink_model_name
if (~mopen)
    disp('Loading model...');
    load_system('realTimeProcessing');  % simulink_model_name
    disp('... done.');
    disp(' ');
end
disp('=====================================================================');

%% Simulate the model

disp(' ');
disp('Simulation running...');

% Run the model
sim('realTimeProcessing', 'Stoptime', '20');                     % simulink_model_name
disp('realTimeProcessing done.');
sound(offlineFilteredOutput.signals.values, FS);
disp(' ');
disp('Results');

