% Find handle to hidden figure
temp = get(0,'showHiddenHandles');
set(0,'showHiddenHandles','on');
hfig = gcf;
% Get the handles structure
handles = guidata(hfig);
event = struct('Source', handles, 'EventName', 'ButtonPushed' );
%==========
set(handles.radioField, 'Value', 1);

name = '10 + t^2';
n = 50;

set(handles.input, 'String', name );
feval(get(handles.input,'Callback'),handles, event);
set(handles.axisStart, 'String', '0');
set(handles.axisEnd, 'String', '10');
set(handles.stepSize, 'String', '0.01');
set(handles.refineOutput, 'String', '1');

for i = 1:n
    feval(get(handles.run,'Callback'),handles, event);
    s = sprintf('file%d', i);
    set(handles.saveFile, 'String', s );
    feval(get(handles.save,'Callback'),handles, event);
end

%add together in loop
%take average


filename = sprintf('file%d', 1);
data = load(filename);
sum = data.(filename).output.signal;

for j = 2:n
    filename = sprintf('file%d', j);
    data = load(filename);
    sum = sum + data.(filename).output.signal;
end

average = sum/n;

figure;
plot(file1.output.time, average);


noise = file1.output.signal - average;
figure;
plot(file1.output.time, noise);

figure;
histogram(noise, 100);

%===========
set(0,'showHiddenHandles',temp);