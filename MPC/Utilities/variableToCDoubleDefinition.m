function [ ] = variableToCDoubleDefinition( path, varargin )
%VARIABLETOCDEFINITION Converts multiple vectors or matrices to static
%const double C style definitions
%   Detailed explanation goes here

delete(path);
fid = fopen(path,'w');

[filepath,name,ext] = fileparts(path);
fprintf(fid, ['#ifndef ' upper(name) '_H \n#define '  upper(name) '_H\n\n']);

for i=1:nargin-1    
    
    fprintf(fid, ['static const double ' inputname(i+1) '[] = {']);
    
    % Flatten matrices to vector in row-column order
    V = varargin{i}';
    V=V(:);
    
    for k=1:numel(V)
        fprintf(fid, '%.17g', V(k));
        if k ~= numel(V)
            fprintf(fid,', ');
        else
            fprintf(fid,'};\n');
        end
    end
end

fprintf(fid, '\n#endif');
fclose(fid);

end

