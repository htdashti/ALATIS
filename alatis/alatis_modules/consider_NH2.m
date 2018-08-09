% this is to consider protons at amine centers
function updated_prev_Map = consider_NH2(updated_mol_path, updated_prev_Map, updated_mol_temp_path, inchi_temp_path, folder_path)
global Error_Msg
try
    [atom_names, matrix, positions] = convert_mol_to_detailed_graph(updated_mol_path);
    matrix = make_symmetric(matrix);
    Len = length(atom_names);
    Amine = [];
    counter = 0;
    for iter=1:Len
        [flag, indices] = is_amine(iter, atom_names, matrix);
        if flag
            counter = counter+1;
            Amine(counter).index = iter;
            Amine(counter).proton_indices = indices;
            Amine(counter).proton_subsituted = false(length(indices), 1);
        end
    end
    Map = 1:length(atom_names);
    for amine_counter=1:length(Amine)
        out = get_NH2_indices(Amine(amine_counter), positions, updated_mol_path, updated_mol_temp_path, inchi_temp_path, folder_path);
        if ~isempty(out)
            temp = out(1);
            Map(out(1)) = out(2);
            Map(out(2)) = temp;
            temp = updated_prev_Map(Amine(amine_counter).proton_indices(1));
            updated_prev_Map(Amine(amine_counter).proton_indices(1)) = updated_prev_Map(Amine(amine_counter).proton_indices(2));
            updated_prev_Map(Amine(amine_counter).proton_indices(2)) = temp;
        end
    end
    system(sprintf('rm -f %s', updated_mol_temp_path));
    system(sprintf('cp %s %s', updated_mol_path, updated_mol_temp_path));
    update_mol_file(folder_path, updated_mol_temp_path, updated_mol_path, Map);
catch Ex
    Error_Msg{end+1} = 'errors while labeling NH2';
    error('Could not label amines');
end
