% How to Use the GUI with a Script
%================Do Not Edit===============================================
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%================Start Editing=============================================

load_system('stateSpace');

% 1) Choose input type: Field (equation in t)
set(handles.radioField, 'Value', 1);

% 2) Simulation settings (fixed parameters)
set(handles.axisStart, 'String', '0');
set(handles.stepSize,  'String', '0.01');
set(handles.refineOutput, 'String', '1');

% 3) Create 50 log-spaced frequencies from 10^-4 to 10^4
omega_vec = logspace(-4, 4, 50);

% Reverse the vector to start from highest frequency
omega_vec = fliplr(omega_vec);

baseSave = 'bodeRun';

disp('Starting frequency sweep...')

for k = 1:length(omega_vec)

    % TEMPORARY LIMIT: stop after 30 runs
    if k > 30
        disp('Temporary limit reached: stopping after 30 runs.');
        break;
    end

    omega = omega_vec(k);

    % Define sine input at this frequency
    name = sprintf('sin(%f*t)', omega);
    set(handles.input, 'String', name);
    feval(get(handles.input,'Callback'), handles, event);

    % Adjust simulation time:
    % Ensure several cycles for low frequencies
    simEnd = max(10, 20/omega);
    set(handles.axisEnd, 'String', num2str(simEnd));

    % Run the black box
    feval(get(handles.run,'Callback'), handles, event);

    % Save output
    saveName = sprintf('%s_%02d', baseSave, k);
    set(handles.saveFile, 'String', saveName);
    feval(get(handles.save,'Callback'), handles, event);

    fprintf('Saved run %02d | ω = %.4e rad/s\n', k, omega);

end

disp('Frequency sweep complete. Files created (limited to 30).');

%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp);