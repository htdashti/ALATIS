function out = run_get_stero(inchi)
out = [];
STR = '';
content = strsplit(inchi, '/');
for i=length(content):-1:1
    if strcmp(content{i}(1), 't')
        STR = content{i}(2:end);
        break
    end
end
if strcmp(STR, '')
    return
else
    c_str = '';
    for i=1:length(STR)
        if strcmp(STR(i), ',')
            continue;
        end
        if strcmp(STR(i), '?')
            c_str = '';
        else
            if ~isnan(str2double(STR(i)))
                c_str = sprintf('%s%s', c_str, STR(i));
            else
                num = str2double(c_str);
                sign = str2double(sprintf('%s1', STR(i)));
                out = [out;[num, sign]];
                c_str = '';
            end
        end
    end
end
