function generate_ouput_II(folder_path, mol_atom_names, updated_prev_Map, inchi_complete_path, num_updated_indices, input_name, Three_D_flag, pdb_output_name, xyz_output_name, runAC, usremail, netcharge, rdc_file, noe_file, dres_fname)
global amm_is_running Error_Msg updated_mol_name failed_methylene_check  Split_mol_names Split_map_names Warning_to_user 


if str2double(runAC)
    convert_3d_2d(updated_mol_name);
    [atom_names, atom_labels] = get_atom_names(updated_mol_name);
    write_name_labels(fout, atom_names, atom_labels, pdb_output_name, usremail, updated_prev_Map, netcharge, rdc_file, noe_file, dres_fname);
    %send_email_AC('ALATIS-request for antechamber', {'Greetings from NMRFAM,', 'Generating unique atom labels has been completed.', 'You will receive an email regarding your top/par computations. This may take several hours.', '', 'Regards,', 'ALATIS team @ NMRFAM', 'http://alatis.nmrfam.wisc.edu/', 'http://www.nmrfam.wisc.edu/'})
    fprintf(fout, '<br><br>\n');
end
