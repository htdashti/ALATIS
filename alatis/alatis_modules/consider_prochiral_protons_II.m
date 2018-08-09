% this is to substitue protons with D at prochiral centers
function [prev_Map, new_map] = consider_prochiral_protons_II(folder_path, mol_temp_path, inchi, inchi_temp_path, prev_Map)
global Error_Msg
[atom_names, matrix, ~] = convert_mol_to_detailed_graph(mol_temp_path);
matrix = make_symmetric(matrix);
Map = [];
new_map = 1:length(prev_Map);
Len = length(atom_names);
Methylene = [];
counter = 0;
for iter=1:Len
    [flag, indices] = is_methylene(iter, atom_names, matrix);
    if flag
        counter = counter+1;
        Methylene(counter).index = iter;
        Methylene(counter).proton_indices = indices;
        Methylene(counter).proton_subsituted = false(length(indices), 1);
    end
end

if isempty(Methylene)
    return
end
try
    Map = get_prochiral_indices_II(Methylene, mol_temp_path, folder_path, inchi, inchi_temp_path);
catch
    Error_Msg{end+1} = 'error while processing prochiral centers';
    error('error @ prochiral analyses')
end

for i=1:size(Map, 1)
    new_map(Map(i, 1)) = Map(i, 2);
end


adjust = [];
for i=1:size(Map, 1)
    if Map(i, 1) == Map(i, 2)
        continue
    else
        flag_new = 1;
        for j=1:size(adjust, 1)
            if adjust(j, 1) == Map(i, 2) && adjust(j, 2) == Map(i, 1)
                flag_new = 0;
            end
        end
        if flag_new
            adjust = [adjust; Map(i, :)];
        end
    end
end
for i=1:size(adjust, 1)
    temp = prev_Map(adjust(i, 1));
    prev_Map(adjust(i, 1)) = prev_Map(adjust(i, 2));
    prev_Map(adjust(i, 2)) = temp;
end
