
close all;
rosshutdown
rosinit('192.168.0.103'); % Connect to external master


[CMDStatusSub] = rossubscriber('/robot/Status');

msg = receive(CMDStatusSub, 1000); % With 1000ms timeout
data = repmat(msg, 100000,1);

i = 1;
while 1
    try
        data(i) = receive(CMDStatusSub, 10); % With 10ms timeout
    catch
        i = i-1;
    end
    i = i+1;
end

plotData = [];
for i=1:100000
    plotData.X(i,:) = [data(i).State.X data(i).Reference.X];
    plotData.Y(i,:) = [data(i).State.Y data(i).Reference.Y];
end

figure;
plot(plotData.X,plotData.Y);



