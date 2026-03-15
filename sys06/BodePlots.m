% How to Use the GUI with a Script
%================Do Not Edit===============================================
% Find handle to hidden figure
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
% Get the handles structure
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );

%================Start Editing=============================================
load_system('stateSpace');
% This will let you pick the Field radio button
set(handles.radioField, 'Value', 1);

% looping through freqs
for i = -20:20
    exp = 2*i/10;
    omega = 10 ^ exp;
    T = 2*pi/omega;
    name = sprintf('sin(%g*t)', omega);

    set(handles.input, 'String', name);
    set(handles.axisStart,    'String', '0');

    num_cycles = 5; %alter as needed
    runtime = T*num_cycles;
    set(handles.axisEnd, 'String', num2str(runtime));

    samples_per_period = 100;
    set(handles.stepSize, 'String', num2str(T/samples_per_period));
    set(handles.refineOutput, 'String', '1');

    feval(get(handles.input,'Callback'), handles, event);
    feval(get(handles.run,'Callback'), handles, event);
    
    tmp = 'tmp_unfiltered';
    set(handles.saveFile, 'String', tmp);
    feval(get(handles.save, 'Callback'), handles, event);

    S = load([tmp '.mat']);
    t = S.(tmp).output.time;
    y = S.(tmp).output.signal;

    dt = t(2) - t(1);
    Fs = 1/dt; %sample rate (per second)

    %using low pass
    
    buffer = 2; % multiplier so that we're not cutting off our signal
    f0 = omega / (2*pi);
    f_cutoff = f0 * buffer; 
    y_filtered = lowpass(y, f_cutoff, Fs);

    save(sprintf('filtered_%.0e.mat', omega), 'omega', 't', 'y', 'y_filtered');

end

delete([tmp '.mat']);
files = dir('filtered_*.mat');
freqs = zeros(1, length(files));
max_vals = zeros(1, length(files));
for k = 1:length(files)
    S = load(files(k).name);
    freqs(k) = S.omega;
    max_vals(k) = max(abs(S.y_filtered));
end

% Sort by frequency
[freqs, idx] = sort(freqs);
max_vals = max_vals(idx);

% Magnitude Bode
figure;
semilogx(freqs, 20*log10(max_vals), '-o');
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('Bode Magnitude Plot');
grid on;

phase_vals = zeros(1, length(files));

for k = 1:length(files)

    S = load(files(k).name);
    omega_k = S.omega;
    T_k = 2*pi / omega_k;

    % trim both arrays to the same length
    n = min(length(S.t), length(S.y_filtered));
    t_trim = S.t(1:n);
    y_trim = S.y_filtered(1:n);

    % use the last 2 cycles 
    last_two_cycles = false(1, n);
    for j = 1:n
        if t_trim(j) >= (t_trim(end) - 2*T_k)
            last_two_cycles(j) = true;
        end
    end

    t_s = t_trim(last_two_cycles);
    t_s = t_s - t_s(1);  % start time at 0
    y_s = y_trim(last_two_cycles);

    % use least squares
    num_points = length(t_s);
    A = zeros(num_points, 2);
    for i = 1:num_points
        A(i, 1) = sin(omega_k * t_s(i));
        A(i, 2) = cos(omega_k * t_s(i));
    end

    coeffs = A \ y_s(:);
    a = coeffs(1);  % sin coefficient
    b = coeffs(2);  % cos coefficient

    % calculate the phase angle in degrees
    phi_rad = atan2(b, a);
    phase_vals(k) = phi_rad * (180/pi);

end

% sort values by frequency and unwrap phase
phase_vals = phase_vals(idx);
phase_vals_rad = phase_vals * (pi/180);
phase_vals_rad = unwrap(phase_vals_rad);
phase_vals = phase_vals_rad * (180/pi);

figure;
semilogx(freqs, phase_vals, '-o');
xlabel('Frequency (rad/s)');
ylabel('Phase (degrees)');
title('Bode Phase Plot');
grid on;
%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp);