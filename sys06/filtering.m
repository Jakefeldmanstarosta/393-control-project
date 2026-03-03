%requires Signal Processing Toolbox
%matlab:matlab.internal.addons.launchers.showExplorer('ErrorRecovery', 'identifier', 'SG', 'focused', 'highpass');

%================Do Not Edit===============================================
% Find handle to hidden figure
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
% Get the handles structure
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%================Start Editing=============================================
% --- Week 7(a): run same input N times and save each run ---
load_system('stateSpace');   
% 1) Choose input type: Field (equation in t)
set(handles.radioField, 'Value', 1);
% 2) Define the input equation as a string in t
name = 'sin(t)';    
set(handles.input, 'String', name );
% IMPORTANT: call this anytime you change the field textbox
feval(get(handles.input,'Callback'), handles, event);
% 3) Simulation settings
set(handles.axisStart, 'String', '0');
set(handles.axisEnd,   'String', '10');
set(handles.stepSize,  'String', '0.01');
set(handles.refineOutput, 'String', '1');
% 4) Run N times and save each output to a different .mat file
% Only do this if files are not already created
N = 50;
baseSave = 'wk7run';
if exist(sprintf('%s_%02d.mat', baseSave, 1), 'file')
   disp('Files already exist, skipping run/save');
else
    for i = 1:N
        % Run the black box
        feval(get(handles.run,'Callback'), handles, event);
    
        % Save output
        saveName = sprintf('%s_%02d', baseSave, i);  
        set(handles.saveFile, 'String', saveName);
        feval(get(handles.save,'Callback'), handles, event);
    end
end
disp('Done saving runs. Files created.');
% ===== LOAD DATA AND AVERAGE =====
disp('Loading runs and averaging...')
% Load first run to get structure
S = load(sprintf('%s_%02d.mat', baseSave, 1));
data = S.(sprintf('%s_%02d', baseSave, 1));
t = data.output.time;
y = data.output.signal;
Y = zeros(N, length(y));
Y(1,:) = y;
% Load remaining runs
for i = 2:N
    fname = sprintf('%s_%02d.mat', baseSave, i);
    S = load(fname);
    data = S.(sprintf('%s_%02d', baseSave, i));
    Y(i,:) = data.output.signal;
end
% Average signal
y_avg = mean(Y, 1);
% Noise extraction
noise = Y(1,:) - y_avg;
% ===== Filtering =====
% compute sampling frequency
dt = t(2) - t(1);   
Fs = 1/dt;           
% High-Pass Filter
high_cutoff = 0.1;                     
y_high = highpass(y_avg, high_cutoff, Fs);
% RMSE for High-Pass Filter
rmse_high = sqrt(mean((y_avg - y_high).^2));
% Low-Pass Filter
low_cutoff = 1;                       
y_low = lowpass(y_avg, low_cutoff, Fs);
% RMSE for Low-Pass Filter
rmse_low = sqrt(mean((y_avg - y_low).^2));


%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp);