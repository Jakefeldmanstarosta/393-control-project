%================Do Not Edit===============================================
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%================Start Editing=============================================

% Low-pass filter cutoff
low_cutoff = 1;  % Hz (adjust if needed)

% Find all bodeRun files
files = dir('bodeRun_*.mat');

for k = 1:length(files)
    filename = files(k).name;
    
    % Load the run
    S = load(filename);
    varname = filename(1:end-4); % remove '.mat'
    data = S.(varname);
    
    t = data.output.time;
    y = data.output.signal;
    
    % Compute sampling frequency
    dt = t(2) - t(1);
    Fs = 1/dt;
    
    % Apply low-pass filter
    y_low = lowpass(y, low_cutoff, Fs);
    
    % Compute RMSE
    rmse_low = sqrt(mean((y - y_low).^2));
    fprintf('%s | RMSE Low-Pass: %.4e\n', filename, rmse_low);
    
    % Save filtered signal
    filteredFile = sprintf('%s_lowpass.mat', varname);
    filtered_data.time = t;
    filtered_data.original = y;
    filtered_data.low = y_low;
    save(filteredFile, 'filtered_data');
    
    % Optional: plot (comment out for speed)
    % figure;
    % plot(t, y, 'DisplayName','Original'); hold on;
    % plot(t, y_low, 'DisplayName','Low-pass filtered');
    % legend; grid on; title(sprintf('%s Filtered', varname));
end

disp('Low-pass filtering complete for all runs.');



%=======================Do Not Edit========================================
set(0,'showHiddenHandles',temp);