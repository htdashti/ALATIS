function [flag, indices, other_heavy] = is_CH3(iter, atom_names, matrix)
flag = false;
indices = [];
other_heavy = [];
if strcmpi(atom_names{iter}, 'H') || strcmpi(atom_names{iter}, 'D') || strcmpi(atom_names{iter}, 'T')
    return
end
vect = matrix(iter, :);
list = find(vect~=0);
if length(list) ~= 4
    return
end

list_names = atom_names(list);

for i=1:length(list_names)
    if strcmp(list_names{i}, 'H') 
        indices = [indices; list(i)];
    else
        other_heavy = [other_heavy;list(i)]; 
    end
end
if length(indices) ~= 3 || length(other_heavy) ~= 1
    return
end
flag = true;
