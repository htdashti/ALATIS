function [flag, indices] = is_amine(iter, atom_names, matrix)
flag = false;
indices = [];
if ~strcmpi(atom_names{iter}, 'N')
    return
end
vect = matrix(iter, :);
list = find(vect~=0);
list_names = atom_names(list);
c_indices = [];
for i=1:length(list_names)
    if (strcmpi(list_names{i}, 'H'))
        indices = [indices; list(i)];
    end
    if (strcmpi(list_names{i}, 'D')) || (strcmpi(list_names{i}, 'T')) % if D-N-H, or T-N-H, we do NOT consider it as an amine.
        return
    end
    if (strcmpi(list_names{i}, 'C'))
        c_indices = [c_indices; list(i)];
    end
end
if length(c_indices) > 1 % more than one carbone is attached
    return;
end
c_bonds_list = find(matrix(c_indices, :));
if length(c_bonds_list) > 3 % C is connected to more than three atoms
    return;
end
c_bonds_names = atom_names(c_bonds_list);
N_flag = 0;
O_flag = 0;
for i=1:length(c_bonds_list)
    if (strcmpi(c_bonds_names{i}, 'O'))
        O_flag = 1;
    end
    if (strcmpi(c_bonds_names{i}, 'N'))
        N_flag = 1;
    end
end
if N_flag == 0 || O_flag == 0
    return;
end
if length(indices) == 2 && length(list) >= 3
    flag = true;
end
