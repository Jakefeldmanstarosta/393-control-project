%requires Signal Processing Toolbox

%================Do Not Edit===============================================
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%================Start Editing=============================================

% Load model + set a simple input
load_system('stateSpace');

set(handles.radioField, 'Value', 1);          % Field (equation in t)
name = 'sin(t)';
set(handles.input, 'String', name);
feval(get(handles.input,'Callback'), handles, event);

set(handles.axisStart, 'String', '0');
set(handles.axisEnd,   'String', '10');
set(handles.stepSize,  'String', '0.01');
set(handles.refineOutput, 'String', '1');

% Run ONCE
feval(get(handles.run,'Callback'), handles, event);

% Save ONCE to a temp file using the app's own save mechanism
tmp = 'tmp_filter_run';
set(handles.saveFile, 'String', tmp);
feval(get(handles.save,'Callback'), handles, event);

% Load the saved struct (your files store a variable with the same name)
S = load([tmp '.mat']);
runData = S.(tmp);

t = runData.output.time;
y = runData.output.signal;

% ===== Low-pass filtering only =====
dt = t(2) - t(1);
Fs = 1/dt;

low_cutoff = 0.1;          % Hz (tune as needed)
y_low = lowpass(y, low_cutoff, Fs);

% Plot ONLY the filtered signal
figure;
plot(t, y_low);
title('Low-Pass Filtered Output');
grid on;

% Optional cleanup:
% delete([tmp '.mat']);