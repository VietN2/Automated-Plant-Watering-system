git %% Automated Plant Watering System (Real-Time MATLAB + Arduino)

clear all;
close all;

% --- Initialize Arduino ---
a = arduino('COM4', 'Uno');

% --- Soil moisture thresholds ---
reallyDryValue = 3.5;
moistureThreshold = 3;
saturatedValue = 2.6;

% --- Setup real-time graph ---
[h, ax, startTime] = setupGraph(1, 4);

% --- Main loop ---
disp('Starting real-time plant monitoring...');
while true
    % --- Read soil moisture voltage ---
    voltage = readVoltage(a, 'A1');
    
    % --- Update graph ---
    t = datetime('now') - startTime;              % Time since start
    addpoints(h, datenum(t), voltage);           % Add new point
    ax.XLim = datenum([t - seconds(60), t]);     % Show last 60 seconds
    datetick('x', 'keeplimits');                 % Format X-axis as time
    drawnow;                                     % Refresh plot
    
    % --- Watering logic ---
    if voltage > reallyDryValue
        disp('The soil is really dry, watering plant...');
        writeDigitalPin(a, 'D2', 1);
        pause(4);                                % Water for 4 seconds
        writeDigitalPin(a, 'D2', 0);
        disp(['Plant watered, voltage: ', num2str(voltage)]);
        
    elseif voltage > moistureThreshold
        disp('Soil moderately dry, watering plant...');
        writeDigitalPin(a, 'D2', 1);
        pause(3);                                % Water for 3 seconds
        writeDigitalPin(a, 'D2', 0);
        disp(['Soil watered, voltage: ', num2str(voltage)]);
        
    else
        disp(['Soil does not need water, voltage: ', num2str(voltage)]);
    end
    
    pause(1); % Short delay between readings
end

% --- Cleanup on exit ---
% clear a; % Uncomment if you plan to stop the script manually

%% --- Functions ---
function [h, ax, startTime] = setupGraph(minY, maxY)
    figure('Name','Plant Moisture Monitoring','NumberTitle','off');
    ax = gca;
    ax.YGrid = 'on';
    ax.YLim = [minY, maxY];
    
    title('Moisture Level vs Time');
    ylabel('Moisture Level (1-4)');
    xlabel('Time');
    
    h = animatedline('Color', 'r', 'LineWidth', 2);
    startTime = datetime('now');
end