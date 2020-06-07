function out = import_data(path)
fileID = fopen(path);

% Partition rows into chunks of data
k = 1;
while(~feof(fileID))
   % Get line of headers
   header_lines{k} = fgetl(fileID);
   headers = strsplit(header_lines{k}, ',');
   headers = headers(1:numel(headers)-1); % Delete empty element
   
   % Read block of data to next set of headers
   data = textscan(fileID, '%f', 'Delimiter', ',');
   data = data{1};
   data = reshape(data, numel(headers), numel(data)/numel(headers))';
   
   block{k} = data;
   k=k+1;
end

types = unique(header_lines);


for i = 1:numel(types)
    indices = find(strcmp(types{i}, header_lines'));
    
    concat_data{i}.data = block{indices(1)};
    concat_data{i}.headers = strsplit(types{i}, ',');
    concat_data{i}.headers = concat_data{i}.headers(1:numel(concat_data{i}.headers)-1);
    
    for k = 2:numel(indices)
       concat_data{i}.data = [concat_data{i}.data; block{indices(k)}]; 
    end
    
    for k = 1:numel(concat_data{i}.headers)
        % Do we need to replace a name ending with .1 .2 .3 etc
        exp = '\.(\d+)';
        rep = '($1,:)';
        concat_data{i}.headers{k} = regexprep(concat_data{i}.headers{k}, exp, rep);
        
        eval(['out.', concat_data{i}.headers{k}, ' = concat_data{i}.data(:,k);']);
    end
    
end


fclose(fileID);

% use unique() to find names of clusters
end