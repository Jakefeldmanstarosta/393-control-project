% ================== Bode Magnitude & Phase Calculation ==================
clear; clc;

baseSave = 'bodeRun';
numRuns = 30;

freq_vec = zeros(1,numRuns);
mag_vec  = zeros(1,numRuns);
phase_vec = zeros(1,numRuns);

for k = 1:numRuns
    % Load filtered data
    filename = sprintf('%s_%02d_lowpass.mat', baseSave, k);
    S = load(filename);
    data = S.filtered_data;
    
    t = data.time;
    y = data.low;   % filtered output
    % Recreate input sine function (same frequency used in this run)
    omega = logspace(-4,4,50);        % original omega vector
    omega = fliplr(omega);            % highest freq first
    if k > length(omega)
        warning('Run index exceeds omega vector');
        break;
    end
    w = omega(k);
    u = sin(w*t);  % input signal
    
    % ---- Magnitude ----
    mag_vec(k) = max(y) / max(u);   % ratio of output peak / input peak
    
    % ---- Phase ----
    % Find first positive peak of input and output
    [~, idx_u] = max(u);
    [~, idx_y] = max(y);
    t_delay = t(idx_y) - t(idx_u);         % time delay
    phase_rad = w * t_delay;               % radians
    phase_vec(k) = phase_rad * (180/pi);   % degrees
    freq_vec(k) = w;                        % store frequency
end

% ---- Plot Bode Magnitude (dB) ----
figure;
semilogx(freq_vec, 20*log10(mag_vec), '-o', 'LineWidth',1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Magnitude (dB)');
title('Bode Plot - Magnitude');

% ---- Plot Bode Phase ----
figure;
semilogx(freq_vec, phase_vec, '-o', 'LineWidth',1.5);
grid on;
xlabel('Frequency (rad/s)');
ylabel('Phase (deg)');
title('Bode Plot - Phase');