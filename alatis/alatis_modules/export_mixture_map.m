function export_mixture_map(updated_mol_path, folder_path, SALTS, protons_bonds, updated_prev_Map)
global mol_f_name Split_mol_names Split_map_names

[Begin, End, atoms, edges] = parse_input_mol(updated_mol_path);
for i=1:length(SALTS)
    fname = sprintf('alatis_molecule_%d_%s', i, mol_f_name);
    fname_map = sprintf('alatis_map_%d_%s.txt', i, strrep(strrep(mol_f_name, '.mol', ''), '.sdf', ''));
    Split_mol_names{end+1} = fname;
    Split_map_names{end+1} = fname_map;
    fout = fopen(sprintf('%s/%s', folder_path, fname), 'w');
    fout_map = fopen(sprintf('%s/%s', folder_path, fname_map), 'w');
    fprintf(fout_map, 'new index\tatom name\toriginal index\n');
    num_atoms = length(SALTS(i).heavy_atom_indices)+length(SALTS(i).protons);
    num_bonds = 0;
    selected_edges = [];
    if ~isempty(SALTS(i).heavy_atom_indices)
        for j=1:length(edges)
            if min(abs(edges(j).from-SALTS(i).heavy_atom_indices)) == 0 || min(abs(edges(j).to-SALTS(i).heavy_atom_indices)) == 0 
                num_bonds = num_bonds+1;
                selected_edges = [selected_edges; j];
            end
        end
        fprintf(fout, '%s_mol_%d\n', strrep(strrep(mol_f_name, '.mol', ''), '.sdf', ''), i);
        fprintf(fout, '    alatis_inchified_mixture\n\n');
        fprintf(fout, '%3d%3d  0  0  0  0            999 V2000\n', num_atoms, num_bonds);
        Map = [];
        Prev_Map = [];
        for j=1:length(SALTS(i).heavy_atom_indices)
            index = SALTS(i).heavy_atom_indices(j);
            Map = [Map; [index, j]];
            Prev_Map = [Prev_Map; [j, updated_prev_Map(index)]];
            fprintf(fout_map, '%d\t%s\t%d\n', j, atoms{index}(31:33), updated_prev_Map(index));
            fprintf(fout, '%s\n', atoms{index});
        end
        for j=1:length(SALTS(i).protons)
            index = SALTS(i).protons(j);
            Map = [Map; [index, length(SALTS(i).heavy_atom_indices)+j]];
            Prev_Map = [Prev_Map; [length(SALTS(i).heavy_atom_indices)+j, updated_prev_Map(index)]];
            fprintf(fout_map, '%d\t%s\t%d\n', length(SALTS(i).heavy_atom_indices)+j, atoms{index}(31:33),updated_prev_Map(index));
            fprintf(fout, '%s\n', atoms{index});
        end
        for j=1:length(selected_edges)
            edge_index = selected_edges(j);
            new_from = Map((edges(edge_index).from == Map(:, 1)), 2);
            new_to = Map((edges(edge_index).to== Map(:, 1)), 2);
            fprintf(fout, '%3d%3d', new_from, new_to);
            for k=1:length(edges(edge_index).rest)
                fprintf(fout, '%3d', edges(edge_index).rest(k));
            end
            fprintf(fout, '\n');
        end
        if ~isempty(Map)
            for j=1:length(End)
                if ~isempty(strfind(End{j}, 'CHG')) || ~isempty(strfind(End{j}, 'RAD'))
                    num_chg_atoms = str2double(End{j}(7:9));
                    charges = [];
                    index = 9;
                    for k=1:num_chg_atoms
                        atom_index = str2double(End{j}(index+2:index+4));
                        atom_charge = str2double(End{j}(index+6:min(length(End{j}), index+8)));
                        index = index+8;
                        charges = [charges; [atom_index, atom_charge]];
                    end
                    new_charges = [];
                    for k=1:size(charges, 1)
                        if ~isempty(Map(charges(k, 1) == Map(:, 1),2))
                            new_charges = [new_charges; [Map(charges(k, 1) == Map(:, 1),2), charges(k, 2)]];
                        end
                    end
                    if ~isempty(new_charges)
                        if ~isempty(strfind(End{j}, 'CHG'))
                            fprintf(fout, 'M  CHG%3d', size(new_charges, 1));
                        else
                            fprintf(fout, 'M  RAD%3d', size(new_charges, 1));
                        end
                        for k=1:size(new_charges, 1)
                            fprintf(fout, ' %3d %3d', new_charges(k, 1), new_charges(k, 2));
                        end
                        fprintf(fout, '\n');
                    end
                end
            end
        end
    end
    fprintf(fout, 'M  END\n');
    fclose(fout);
    fclose(fout_map);
end
