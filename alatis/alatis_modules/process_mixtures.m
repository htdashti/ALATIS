function updated_prev_Map = process_mixtures(updated_prev_Map, inchi_inchi_path, updated_mol_path, folder_path, updated_mol_temp_path)
fin = fopen(inchi_inchi_path, 'r');
main_inchi = fgetl(fin);
fclose(fin);
[inchis, ~] = split_inchi(main_inchi);
current_len = 0;
salt_counter = 0;
SALTS = [];
for i=1:length(inchis)
    content = strsplit(inchis{i}, '/');
    [inchi_names, ~] = convert_inchi_heavy_atoms_to_graph(inchis{i});
    if ~is_salt(content{2})
        current_len = current_len+length(inchi_names);
        continue
    end
    salt_counter = salt_counter+1;
    SALTS(salt_counter).heavy_atom_indices = current_len+1:current_len+length(inchi_names);
    SALTS(salt_counter).protons = [];
    current_len = current_len+length(inchi_names);
end
if ~isempty(SALTS) && length(SALTS)>1
    
    [~, ~, protons_bonds, ~] = convert_mol_heavy_atoms_to_graph(updated_mol_path);
    for i=1:length(SALTS)
        for j=1:length(SALTS(i).heavy_atom_indices)
            for k=1:size(protons_bonds, 1)
                if protons_bonds(k, 1) == SALTS(i).heavy_atom_indices(j)
                    SALTS(i).protons = [SALTS(i).protons; protons_bonds(k, 2)];
                end
                if protons_bonds(k, 2) == SALTS(i).heavy_atom_indices(j)
                    SALTS(i).protons = [SALTS(i).protons; protons_bonds(k, 1)];
                end
            end
        end
    end
    export_mixture_map(updated_mol_path, folder_path, SALTS, protons_bonds, updated_prev_Map)
    % update prev map
    [updated_prev_Map, new_map] = Update_prev_map_basedon_salts(SALTS, updated_prev_Map);
    
    % update mol file
    system(sprintf('mv %s %s', updated_mol_path, updated_mol_temp_path));
    update_mol_file(folder_path, updated_mol_temp_path, updated_mol_path, new_map);
end
