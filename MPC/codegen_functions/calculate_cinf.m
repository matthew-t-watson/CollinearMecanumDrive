function [ cinf ] = calculate_cinf( x, r, Ginfinv, ny )

% r = zeros(numel(r_reduced)*(8/3),1);
% for i=1:numel(r_reduced/3)
%     r((i-1)*nx+(1:3)) = r_reduced((i-1)*3+(1:3));
% end

cinf = Ginfinv*(x(1:ny)-r(end-ny+1:end));

end

