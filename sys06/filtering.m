%requires Signal Processing Toolbox
%================Do Not Edit===============================================
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%================Start Editing=============================================
load_system('stateSpace');
set(handles.radioField, 'Value', 1);
set(handles.input, 'String', 'sin(10*t)');
feval(get(handles.input,'Callback'), handles, event);
set(handles.axisStart,    'String', '0');
set(handles.axisEnd,      'String', '10');
set(handles.stepSize,     'String', '0.01');
set(handles.refineOutput, 'String', '1');
feval(get(handles.run,'Callback'), handles, event);

tmp = 'tmp_filter_run';
set(handles.saveFile, 'String', tmp);
feval(get(handles.save,'Callback'), handles, event);

S = load([tmp '.mat']);
t = S.(tmp).output.time;
y = S.(tmp).output.signal;

% Low-pass filter
Fs = 1 / (t(2) - t(1));
y_low = lowpass(y, 1, Fs);   % 1 Hz cutoff — tune as needed

% Filtered only
figure; plot(t, y_low); title('Low-Pass Filtered Output'); grid on;

% Comparison
figure;
plot(t, y, 'DisplayName', 'Original'); hold on;
plot(t, y_low, 'DisplayName', 'Filtered');
legend; grid on;

% delete([tmp '.mat']);