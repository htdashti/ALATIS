function updated_prev_Map = consider_D_T(updated_mol_path, updated_prev_Map, updated_mol_temp_path, folder_path)
global Error_Msg
try
    [atom_names, matrix, ~] = convert_mol_to_detailed_graph(updated_mol_path);
    matrix = make_symmetric(matrix);
    Len = length(atom_names);
    proton_isotopes = [];
    counter = 0;
    for iter=1:Len
        [flag, indices] = has_proton_isotope(iter, atom_names, matrix);
        if flag
            counter = counter+1;
            proton_isotopes(counter).index = iter;
            proton_isotopes(counter).proton_indices = indices;
        end
    end
    new_map = 1:length(atom_names);
    for i=1:length(proton_isotopes)
        Map = Label_proton_isotopes(proton_isotopes(i), atom_names);
        for j=1:size(Map, 1)
            new_map(Map(j, 1)) = Map(j, 2);
        end
        updated_prev_Map(Map(:, 1)) = updated_prev_Map(Map(:, 2));
    end
    system(sprintf('rm -f %s', updated_mol_temp_path));
    system(sprintf('cp %s %s', updated_mol_path, updated_mol_temp_path));
    update_mol_file(folder_path, updated_mol_temp_path, updated_mol_path, new_map);
catch
    Error_Msg{end+1} = 'error while processing D, T';
    error('error while processing D, T');
end
