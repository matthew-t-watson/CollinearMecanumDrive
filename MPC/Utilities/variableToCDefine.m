function [ ] = variableToCDefine( path, varargin )
%VARIABLETOCDEFINITION Converts variables to #define x (num) style 
%   Detailed explanation goes here

delete(path);
fid = fopen(path,'w');

[filepath,name,ext] = fileparts(path);
fprintf(fid, ['#ifndef ' upper(name) '_H \n#define '  upper(name) '_H\n\n']);

for i=1:nargin-1
   fprintf(fid, ['#define ' upper(inputname(i+1)) '\t\t(%.17g)\n'], varargin{i});
end

fprintf(fid, '\n#endif');

fclose(fid);

end

