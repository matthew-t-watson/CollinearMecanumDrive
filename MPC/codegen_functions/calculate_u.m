function [ u ] = calculate_u( x, r, c, Pr, K )

% r = zeros(numel(r_reduced)*(8/3),1);
% for i=1:numel(r_reduced/3)
%     r((i-1)*8+(1:3)) = r_reduced((i-1)*3+(1:3));
% end

u = -K*x + Pr*r + c(1:4);

end

