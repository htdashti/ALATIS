function generate_other_FType_outputfiles(updated_mol_path, pdb_output_name, xyz_output_name)
global input_ftype Warning_to_user

[~, ~, ext] = fileparts(updated_mol_path);
type = ext(2:end);
command = sprintf('obabel -i%s %s -oxyz -O %s', type, updated_mol_path, xyz_output_name);
[~, ~] = system(command);
command = sprintf('obabel -i%s %s -opdb -O %s', type, updated_mol_path, 'temp.pdb');
[~, ~] = system(command);

try
    [~, atom_labels] = get_atom_names(updated_mol_path);
    update_pdb(pdb_output_name, 'temp.pdb', atom_labels);
    [~, ~] = system('rm -f temp.pdb');
catch
    Warning_to_user{end+1} = 'Could not update atom names in the pdb output file!';
    Warning_to_user{end+1} = 'Atom labels will change to atom names';
    [~, ~] = system(sprintf('mv temp.pdb %s', pdb_output_name));
end
