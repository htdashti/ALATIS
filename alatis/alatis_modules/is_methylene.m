function [flag, indices] = is_methylene(iter, atom_names, matrix)
flag = false;
indices = [];
if ~strcmpi(atom_names{iter}, 'C')
    return
end
vect = matrix(iter, :);
list = find(vect~=0);
list_names = atom_names(list);

for i=1:length(list_names)
    if (strcmpi(list_names{i}, 'H'))
        indices = [indices; list(i)];
    end
    if strcmpi(list_names{i}, 'D') || strcmpi(list_names{i}, 'T') % if it has D or T, we do NOT consider it as a methylene
        return
    end
end
if length(indices) == 2 && length(list) > 3
    flag = true;
end
