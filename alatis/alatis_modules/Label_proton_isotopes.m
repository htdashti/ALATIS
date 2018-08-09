function Map = Label_proton_isotopes(proton_isotopes, atom_names)
Map = [];
list = proton_isotopes.proton_indices;
s_list = sort(list);
T_list = find(strcmpi(atom_names(list), 'T'));
D_list = find(strcmpi(atom_names(list), 'D'));
H_list = find(strcmpi(atom_names(list), 'H'));

for i=1:length(T_list)
    Map = [Map; [list(T_list(i)), s_list(1)]];
    s_list(1) = [];
end
for i=1:length(D_list)
    Map = [Map; [list(D_list(i)), s_list(1)]];
    s_list(1) = [];
end
for i=1:length(H_list)
    Map = [Map; [list(H_list(i)), s_list(1)]];
    s_list(1) = [];
end
