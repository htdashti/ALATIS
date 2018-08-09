function M = get_NLayer_map(aux_info)
M = [];
content = strsplit(aux_info, '/');
for i=1:length(content)
    if ~isempty(strfind(content{i}, 'N:'))
        line = strrep(content{i}, 'N:', '');
        content = strsplit(line, ',');
        for j=1:length(content)
            M = [M; [j, str2double(content{j})]];
        end
        return
    end
end
