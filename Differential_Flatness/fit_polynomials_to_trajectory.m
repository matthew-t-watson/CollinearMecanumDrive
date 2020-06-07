function [p,durations] = fit_polynomials_to_trajectory(pv,dt,segmentTime,degree)

numSegments = ceil(size(pv,2)*dt/segmentTime);
stepsPerSegment = floor(segmentTime/dt);

% Split pv into fixed size segment chunks
for i=1:floor(size(pv,2)/stepsPerSegment)
    pvSplit{i} = pv(:,(1:stepsPerSegment)+stepsPerSegment*(i-1));
end
% Fit remainder of pv into final chunk
pvSplit{end+1} = pv(:,end-mod(size(pv,2),stepsPerSegment)+1:end);

pvNew = [];
for i=1:numSegments
    t{i} = 0:dt:(size(pvSplit{i},2)-1)*dt;
    if i < numSegments
        for j=1:3
            % Force to end at the start of next
            p{j}(:,i) = polyfix(t{i}, pvSplit{i}(j,:), degree(j), [0 t{i}(end)+dt], [pvSplit{i}(j,1) pvSplit{i+1}(j,1)])';
        end
        
        % Evaluate polynomials for comparison
        pvNew = [pvNew [polyval(p{1}(:,i),t{i}); polyval(p{2}(:,i),t{i}); polyval(p{3}(:,i),t{i})]];
    else
        for j=1:3
            p{j}(:,i) = polyfix(t{i}, pvSplit{i}(j,:), degree(j), [0 t{i}(end)], [pvSplit{i}(j,1) pvSplit{i}(j,end)])';
        end
        
        % Evaluate polynomials for comparison
        pvNew = [pvNew [polyval(p{1}(:,i),t{i}); polyval(p{2}(:,i),t{i}); polyval(p{3}(:,i),t{i})]];
    end
    
    durations(i) = t{i}(end);
    
end


% % Flip polycoefs order
% for i=1:3
%     p{i} = flipud(p{i});
% end

figure; subplot(2,1,1); plot(pv(1,:),pv(2,:),pvNew(1,:),pvNew(2,:));
subplot(2,1,2); plot([pv - pvNew]');

