
% close all;

% data = import_data('data_200418_1325 - current error analysis.csv');
% data = import_data('data_200418_1419 - current error analysis 2.csv');
% data = import_data('data_200418_1526 current error analysis 3 - big wobble.csv');
data = import_data('data_200418_1716 - current error analysis 4 - looks fixed.csv');

figure;
subplot(3,1,1); plot(data.sensors.Motor_Current'); title('Actual current');
subplot(3,1,3); plot(data.sensors.Demanded_Current'); title('Demand current');
subplot(3,1,2); plot(data.sensors.Demanded_Current' - data.sensors.Motor_Current'); title('Current error');

all_ha = findobj( gcf, 'type', 'axes', 'tag', '' );
linkaxes( all_ha, 'x' );