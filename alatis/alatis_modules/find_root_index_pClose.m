function [index, error_msg] = find_root_index_pClose(n_list, c_list, c_index)
index = 0;
error_msg = '';
if strcmp(c_list(c_index), ')')
    counter = -1;
else
    counter = 0;
end
for iter = c_index:-1:1
    if strcmp(c_list(iter), ')')
        counter = counter+1;
    end
    if strcmp(c_list(iter), '(')
        if counter == 0
            index = n_list(iter);
            return
        else
            counter = counter-1;
        end
    end
end
error_msg = 'syntax error';
