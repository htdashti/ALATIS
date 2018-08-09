function merged = merge_split_char_vs_nums(STR)
merged = [];
array = isnan(str2double(STR));
c_list = [];
n_list = [];
iter = 1;
while iter <= length(array)
    %array(iter)
    %STR(iter)
    if array(iter) == 1
        c_list{end+1} = STR{iter};
        merged{end+1} = STR{iter};
        iter = iter+1;        
    else
        if strcmp(STR(iter), 'i')
            merged{end} = sprintf('%si', merged{end});
            iter=iter+1;
        else
            temp = '';
            while iter <=length(array) && ~array(iter)==1
                temp = sprintf('%s%s', temp, STR{iter});
                iter = iter+1;
            end
            n_list(end+1) = str2double(temp);
            merged{end+1} = str2double(temp);
        end
    end
end
Removed = false(length(merged), 1);
for i=1:length(merged)
    if strcmp(merged{i}, '-')
        start = merged{i-1};
        end_p = merged{i+1};
        if ~isnumeric(end_p)
            end_p = 1;
            for j=i+2:length(merged)
                if isnumeric(merged{j})
                    end_p = merged{j};
                    break
                end
            end
        end
        merged{i-1} = start:end_p;

        Removed(i) = true;
        Removed(i+1) = true;
    end
end
merged(Removed) = [];
