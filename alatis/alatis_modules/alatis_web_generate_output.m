function alatis_web_generate_output(folder_path, input_name, inchi_complete_path, pdb_output_name, xyz_output_name, Three_D_flag, updated_mol_path)
global Error_Msg

if isempty(Error_Msg)
    generate_other_FType_outputfiles(updated_mol_path, pdb_output_name, xyz_output_name);
end
write_sdf_output(folder_path, Three_D_flag);
write_display_info(folder_path, input_name, inchi_complete_path, pdb_output_name, xyz_output_name,Three_D_flag);
compress_outputs(folder_path, input_name, pdb_output_name, xyz_output_name);

function compress_outputs(folder_path, input_name, pdb_output_name, xyz_output_name)
global updated_mol_name compact_sdf_output_name
Here = pwd;
cd(folder_path);
List = dir('./');
Command = sprintf('zip outputs.zip %s display_info map.txt inchi_complete.inchi inchi.inchi %s %s %s %s ', compact_sdf_output_name, input_name, updated_mol_name, pdb_output_name, xyz_output_name);
for i=3:length(List)
    if ~isempty(strfind(List(i).name, 'alatis_map_'))
        Command= sprintf('%s %s', Command, List(i).name);
    end
    if ~isempty(strfind(List(i).name, 'alatis_molecule_'))
        Command = sprintf('%s %s', Command, List(i).name);
    end
end
[~, ~] = system(Command);
cd(Here);


function write_sdf_output(folder_path, Three_D_flag)
global updated_mol_name Warning_to_user Error_Msg failed_methylene_check Split_map_names compact_sdf_output_name
% write output mol file
fout = fopen(sprintf('%s/%s', folder_path, compact_sdf_output_name), 'w');
if exist(updated_mol_name, 'file')
    filetext = fileread(updated_mol_name);
    fprintf(fout, '%s\n', strrep(filetext, '$$$$', ''));
end
% write standard inchi
if exist('inchi_complete.inchi', 'file')
    fprintf(fout,'>  <ALATIS_Standard_InChI>\n');
    fin = fopen('inchi_complete.inchi', 'r');
    tline = fgetl(fin);
    fprintf(fout, '%s\n\n', tline);
    fclose(fin);
end
% write warnings
fprintf(fout,'>  <ALATIS_Warnings>\n');
for i=1:length(Warning_to_user)
    fprintf(fout, '%s\n', Warning_to_user{i});
end
if Three_D_flag == 0
    fprintf(fout, 'It seems the input file contains a 2D structure (z-coordinates are 0).\nWe did not consider the sterochemistry of the compound, and protons at prochiral centers have not been analyzed!');
end
fprintf(fout,'\n');

% write errors
fprintf(fout,'>  <ALATIS_Errors>\n');
for i=1:length(Error_Msg)
    fprintf(fout, '%s\n', Error_Msg{i});
end
if failed_methylene_check == 1
    fprintf(fout, 'Maximum number of iterations reached:<br>1024 different configurations of substitutions on prochiral centers have been considered but the program has not converged. If you are interested to check all of the possibilities please contact "dashti@wisc.edu".\n');
end
fprintf(fout,'\n');

% write map:
fprintf(fout,'>  <ALATIS_Map>\n');
if exist(sprintf('%s/map.txt', folder_path), 'file')
    filetext = fileread(sprintf('%s/map.txt', folder_path));
    fprintf(fout, '%s\n', filetext);
end
fprintf(fout,'\n');

% write mixture map
fprintf(fout,'>  <ALATIS_Mixture_Map>\n');
for i=1:length(Split_map_names)
    if exist(Split_map_names{i}, 'file')
        fprintf(fout, 'molecule_%d\n', i);
        filetext = fileread(Split_map_names{i});
        fprintf(fout, '%s\n', filetext);
    end
end
fprintf(fout,'\n');
fprintf(fout,'$$$$\n');
fclose(fout);

function write_display_info(folder_path, input_name, inchi_complete_path, pdb_output_name, xyz_output_name, Three_D_flag)
global Error_Msg Warning_to_user failed_methylene_check updated_mol_name Split_mol_names Split_map_names compact_sdf_output_name

% generating display_info for flask web display
fout = fopen(sprintf('%s/display_info', folder_path), 'w');

fprintf(fout, '>  <ALATIS_Warnings>\n');
if ~isempty(Warning_to_user) || Three_D_flag == 0 || failed_methylene_check == 1
    for i=1:length(Warning_to_user)
        fprintf(fout, '%s\n', Warning_to_user{i});
    end
    if Three_D_flag == 0
        fprintf(fout, 'It seems the input file contains a 2D structure (z-coordinates are 0). \nWe did not consider the sterochemistry of the compound, and protons at prochiral centers have not been analyzed!\n');    
    end
    if failed_methylene_check == 1
        fprintf(fout, 'Maximum number of iterations reached: 1024 different configurations of substitutions on prochiral centers have been considered but the program has not converged. If you are interested to check all of the possibilities please contact "dashti@wisc.edu".\n');
    end
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_Errors>\n');
if ~isempty(Error_Msg) % reporting errors and exiting
    for i=1:length(Error_Msg)
        fprintf(fout, '%s\n', Error_Msg{i});
    end
    fprintf(fout, 'Please contact dashti@wisc.edu to discuss and fix the problem.\n');
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_compact_sdf>\n');
if exist(sprintf('%s/%s', folder_path, compact_sdf_output_name), 'file')
    fprintf(fout, '%s\n',compact_sdf_output_name);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_complete_inchi>\n');
if exist(sprintf('%s/%s', folder_path, inchi_complete_path), 'file')
    fprintf(fout, '%s\n', inchi_complete_path);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_output_pdb>\n');
if exist(pdb_output_name, 'file')
    fprintf(fout, '%s\n', pdb_output_name);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_output_xyz>\n');
if exist(xyz_output_name, 'file')
    fprintf(fout, '%s\n', xyz_output_name);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_input>\n');
if exist(input_name, 'file')
    fprintf(fout, '%s\n', input_name);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_output_mol>\n');
if exist(updated_mol_name, 'file')
    fprintf(fout, '%s\n', updated_mol_name);
end
fprintf(fout, '\n');

fprintf(fout, '>  <ALATIS_output_map>\n');
if exist('map.txt', 'file')
    fprintf(fout, '%s\n', 'map.txt');
end    
fprintf(fout, '\n');
    
fprintf(fout, '>  <ALATIS_output_mixture_info>\n');
if ~isempty(Split_mol_names)
    for i=1:length(Split_mol_names)
        fprintf(fout, '%s,%s\n', Split_mol_names{i}, Split_map_names{i});
    end
end
fprintf(fout, '\n');

fprintf(fout, '$$$$\n');
fclose(fout);

