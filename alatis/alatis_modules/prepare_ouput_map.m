function prepare_ouput_map(folder_path, mol_atom_names, updated_prev_Map)
global Original_input_atom_names
fout = fopen(sprintf('%s/map.txt', folder_path), 'w');
fprintf(fout, 'new index\tatom name\toriginal index\n');
for i=1:size(mol_atom_names, 1)
    fprintf(fout, '%d\t%s\t%d\n', i, mol_atom_names{updated_prev_Map(i)}, updated_prev_Map(i));
end

if ~isempty(Original_input_atom_names)
    if length(Original_input_atom_names) == length(mol_atom_names)
        fprintf(fout, '\n\n#Map between atom labels\n');
        fprintf(fout, 'new label\toriginal label\n');
        for i=1:size(mol_atom_names, 1)
            fprintf(fout, '%s%d\t%s\n', mol_atom_names{updated_prev_Map(i)}, i, Original_input_atom_names{updated_prev_Map(i)});
        end 
    end
end
fclose(fout);
