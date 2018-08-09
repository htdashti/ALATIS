function write_name_labels(fout, atom_names, atom_labels, pdb_output_name, usremail, updated_prev_Map, netcharge, rdc_file, noe_file, dres_fname)
global Original_input_atom_names autogen_atomnames_flag
fprintf(fout, '<form action="upload.php" method="post" enctype="multipart/form-data" target="_blank">\n');
fprintf(fout, '<table border="1" align="center">\n');
fprintf(fout, '<tr><td colspan="2" align="center"><img src="gissmo.svg" alt="2D projection"></td></tr>');
fprintf(fout, '<tr align="center"><td>Unique atom index</td><td>Customized label</td></tr>\n');
if ~isempty(Original_input_atom_names) && autogen_atomnames_flag == 0 && length(atom_names) == length(Original_input_atom_names)
    for i=1:length(atom_names)
        fprintf(fout, '<tr align="center"><td>%d</td><td><input type="text" value="%s" name="atomlabel%d" id="atomlabel%d"></td></tr>\n', i, Original_input_atom_names{updated_prev_Map(i)}, i, i);
    end
else
    for i=1:length(atom_names)
        fprintf(fout, '<tr align="center"><td>%d</td><td><input type="text" value="%s" name="atomlabel%d" id="atomlabel%d"></td></tr>\n', i, atom_labels{i}, i, i);
    end
end
fprintf(fout, '</table>\n<br>\n');
fprintf(fout, '<p align="center"><input type="submit" value="Submit for topology/parameter calculation"</p>');

write_acsubmit_php(atom_names, pdb_output_name, usremail, netcharge, rdc_file, noe_file, dres_fname)
