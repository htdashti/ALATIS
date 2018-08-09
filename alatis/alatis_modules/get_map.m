% this function extracts atoms maps from the original input numbering to
% inchi numbering system
function Map = get_map(auxInfo_line)
Map = [];
content = strsplit(auxInfo_line, '/');
for i=1:length(content)
    str = content{i};
    if strcmp(str(1), 'N')
        str = str(3:end);
        content = strsplit(str, ',');
        Map = zeros(1, length(content));
        counter = 0;
        for j=1:length(content)
            if ~isempty(strfind(content{j}, ';'))
                split = strsplit(content{j}, ';');
                for k=1:length(split)
                    counter = counter+1;
                    Map(counter) = str2double(split{k});
                end
            else
                counter = counter+1;
                Map(counter) = str2double(content{j});
            end
        end
        break;
    end
end


