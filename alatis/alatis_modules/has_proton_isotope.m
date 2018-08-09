function [flag, indices] = has_proton_isotope(iter, atom_names, matrix)
flag = false;
indices = [];
if strcmpi(atom_names{iter}, 'H') || strcmpi(atom_names{iter}, 'D') || strcmpi(atom_names{iter}, 'T')
    return
end
vect = matrix(iter, :);
list = find(vect~=0);
list_names = atom_names(list);
D_flag = 0;
T_flag = 0;
for i=1:length(list_names)
    if strcmp(list_names{i}, 'D') 
        indices = [indices; list(i)];
        D_flag = 1;
    end
    if strcmp(list_names{i}, 'T') 
        indices = [indices; list(i)];
        T_flag = 1;
    end
    if strcmp(list_names{i}, 'H') 
        indices = [indices; list(i)];
    end
end
if T_flag == 1 || D_flag == 1
    flag = true;
end
