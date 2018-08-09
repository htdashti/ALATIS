function update_pdb(fname, input_pdb_fname, new_atom_names)
global Error_Msg
fout = fopen(fname, 'w');
fin = fopen(input_pdb_fname, 'r');
tline = fgetl(fin);
atom_counter = 0;
Error_flag = 0;
while ischar(tline)
    if (length(tline) > 4 && strcmp(tline(1:4), 'ATOM')) || (length(tline) > 6 && strcmp(tline(1:6), 'HETATM'))
        text_length = 6;
        atom_counter = atom_counter+1;
        if length(new_atom_names) < atom_counter
            Error_flag = 1;
            break
        end
        if length(new_atom_names{atom_counter}) > 4
            Error_flag = 2;
            break
        end
        tline(text_length+6+1:text_length+6+4) = sprintf('%4s', new_atom_names{atom_counter});
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
end
if Error_flag == 1
    Error_Msg{end+1} = 'There are more atoms in the pdb file than the number of provided custom atom labels';
    error('incorrect number of atoms');
end
if Error_flag == 2
    Error_Msg{end+1} = 'Atom labels cannot be more than 4 characters!';
    error('incorrect length of atom labels');
end
fclose(fin);
fclose(fout);
