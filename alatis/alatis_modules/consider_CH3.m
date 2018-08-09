function updated_prev_Map = consider_CH3(updated_mol_path, updated_prev_Map, updated_mol_temp_path, folder_path)
global Error_Msg
try
    [atom_names, matrix, positions] = convert_mol_to_detailed_graph(updated_mol_path);
    matrix = make_symmetric(matrix);
    Len = length(atom_names);
    CH3 = [];
    counter = 0;
    for iter=1:Len
        [flag, indices, other_heavy] = is_CH3(iter, atom_names, matrix);
        if flag
            counter = counter+1;
            CH3(counter).index = iter;
            CH3(counter).proton_indices = indices;
            CH3(counter).other_heavy = other_heavy;
        end
    end
    new_map = 1:length(atom_names);
    for i=1:length(CH3)
        Map = Label_CH3(CH3(i), atom_names, positions);
        for j=1:size(Map, 1)
            new_map(Map(j, 1)) = Map(j, 2);
        end
        updated_prev_Map(Map(:, 1)) = updated_prev_Map(Map(:, 2));
    end
    system(sprintf('rm -f %s', updated_mol_temp_path));
    system(sprintf('cp %s %s', updated_mol_path, updated_mol_temp_path));
    update_mol_file(folder_path, updated_mol_temp_path, updated_mol_path, new_map);
catch
    Error_Msg{end+1} = 'error while processing methyl group';
    error('error while processing D, T');
end
