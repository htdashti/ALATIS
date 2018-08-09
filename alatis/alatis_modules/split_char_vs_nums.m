function [c_list, n_list] = split_char_vs_nums(STR)
array = isnan(str2double(STR));
c_list = [];
n_list = [];
iter = 1;
while iter <= length(array)
    if array(iter) == 1
        c_list{end+1} = STR{iter};
        iter = iter+1;
    else
        temp = '';
        while iter <=length(array) && ~array(iter)==1
            temp = sprintf('%s%s', temp, STR{iter});
            iter = iter+1;
        end
        n_list(end+1) = str2double(temp);
    end
end
