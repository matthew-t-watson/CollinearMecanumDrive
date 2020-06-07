function [ ] = variableToEigenDefinition( path, varargin )
%VARIABLETOCDEFINITION Converts multiple vectors or matrices to initialised
% Eigen consts
%   Detailed explanation goes here

delete(path);
fid = fopen(path,'w');

for i=1:nargin-1
   fprintf(fid, ['static const Eigen::Matrix<double,' num2str(size(varargin{i},1)) ',' num2str(size(varargin{i},2)) ...
       '> '  inputname(i+1) ' = (Eigen::Matrix<double,' num2str(size(varargin{i},1)) ',' num2str(size(varargin{i},2)) ...
       '> << ']);
   
   % Flatten matrices to vector in row-column order
   V = varargin{i}';
   V=V(:); 
   
   % Print vector to file
   for k=1:numel(V)
      fprintf(fid, '%.17g', V(k));
      if k ~= numel(V)
          fprintf(fid,', ');
      else
          fprintf(fid,').finished();\n');
      end
   end
end

fclose(fid);

end

