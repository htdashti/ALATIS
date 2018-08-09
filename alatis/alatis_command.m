% Input variables:
%Path_to_input_file: path to the input structure file. based on the sh configuration, it may need './'
%input_type: this indicates the input file format and can be 'MOL', 'SDF', 'PDB', 'CDX'.
%project3D_flag: This is a flag and can be '0' or '1'. If the input structure file is a 2D file, set this flag to '1'. This option requires open babel in $PATH.
%addHydrogen_flag: This is a flag and can be '0' or '1'. If the input structure file requires adding explicit H, set this flag to '1'. This option requires open babel in $PATH.
%input_website_folder: to be sent to users when RUNER is running. [For ALATIS set to '.']
function alatis_command(Path_to_input_file, input_type, project3D_flag, addHydrogen_flag, send_email_flag)
clearvars -global
global Error_Msg inchi1_Path mol_f_name Original_input_atom_names Warning_to_user website_folder input_ftype compact_sdf_output_name 
global run_on_box run_test_local

run_on_box = true;
run_test_local = false;
inchi1_Path = './inchi-1';

% This is to load the modules if running the code; binary file doesn't need
% this addpath call

if run_test_local
    addpath(pwd);
    addpath(sprintf('%s/alatis_modules/', pwd))
    inchi1_Path = sprintf('%s/inchi-1', pwd);
    [folder, name, ext] = fileparts(Path_to_input_file);
    cd(folder);
    Path_to_input_file = sprintf('%s%s', name, ext);
    input_type = 'SDF';
    project3D_flag = '0';
    addHydrogen_flag = '0'; 
    input_website_folder = '.';
end

if run_on_box
    [folder, name, ext] = fileparts(Path_to_input_file);
    cd(folder);
    Path_to_input_file = sprintf('%s%s', name, ext);
    run_test_local = true; % to avoid submitting emails
    input_website_folder = '.';
    inchi1_Path = 'inchi-1';
end

% init global variabales
compact_sdf_output_name = 'alatis_output_compact.sdf';
website_folder = input_website_folder;
Warning_to_user = {};
Error_Msg = {};

try
    % define output file names
    xyz_output_name = sprintf('alatis_output_%s.xyz', strrep(Path_to_input_file, '.', '_'));
    pdb_output_name = sprintf('alatis_output_%s.pdb', strrep(Path_to_input_file, '.', '_'));
    
    % check file format
    [~,~,ext] = fileparts(Path_to_input_file);
    if ~strcmpi(ext, sprintf('.%s', input_type))
        Error_Msg{end+1} = 'The chosen file format does not match with the extension of the input file';
        error('Incorrect file format mismathced!');
    end
    
    % converting other input file formats to mol
    % applying aux functionalities
    try
        Original_input_atom_names = {};
        Path_to_input_file = conversion_type_format(Path_to_input_file, input_type, project3D_flag, addHydrogen_flag);
    catch
        Error_Msg{end+1} = 'There was a problem while using obabel for converting file types or performing aux. functions (add H, project to 3D)';
        Error_Msg{end+1} = 'We can help you with these issues. Feel free to contact us (dashti@wisc.edu).';
        error('obabel crashed!');
    end
    
    % setting '.' for HTCondor submissions
    [pathstr,name,ext] = fileparts(Path_to_input_file);
    input_ftype = strrep(ext, '.', '');
    if isempty(pathstr)
        pathstr = '.';
    end
    folder_path = pathstr;
    fname = sprintf('%s%s', name, ext);
    mol_f_name = fname;

    
    % run alatis
    outputs = alatis_core_computation(folder_path, fname);
    % prepare and generate outputs (index.html, outputs.zip)
    try
        prepare_ouput_map(outputs.folder_path, outputs.mol_atom_names, outputs.updated_prev_Map)
        alatis_web_generate_output(outputs.folder_path, outputs.mol_f_name, outputs.inchi_complete_path, pdb_output_name, xyz_output_name, outputs.Three_D_flag, outputs.updated_mol_path);
    catch
        Error_Msg{end+1} = 'error while generating outputs';
        error('generating outputs');
    end

    fclose('all');
catch
    
    if isempty(Error_Msg)
        Error_Msg{end+1} = 'unexpected error!';
    end
    
    [folder_path,~,~] = fileparts(Path_to_input_file);
    if isempty(folder_path)
        folder_path = '.';
    end
    try
        alatis_web_generate_output(folder_path, '.', '.', '.', '.', 0, '.');
    catch
        safe_check_output(folder_path);
    end
    fclose('all');
end
fprintf('Completed!\n')

function safe_check_output(folder_path)
global Warning_to_user Error_Msg compact_sdf_output_name 
fout = fopen(sprintf('%s/%s', folder_path, compact_sdf_output_name), 'w');
% write warnings
fprintf(fout,'>  <ALATIS_Warnings>\n');
for i=1:length(Warning_to_user)
    fprintf(fout, '%s\n', Warning_to_user{i});
end

% write errors
fprintf(fout,'>  <ALATIS_Errors>\n');
for i=1:length(Error_Msg)
    fprintf(fout, '%s\n', Error_Msg{i});
end
fprintf(fout,'\n');
fprintf(fout,'$$$$\n');
fclose(fout);

fout = fopen(sprintf('%s/display_info', folder_path), 'w');
if ~isempty(Warning_to_user) || Three_D_flag == 0 || failed_methylene_check == 1
    fprintf(fout, '>  <ALATIS_Warnings>\n');
    for i=1:length(Warning_to_user)
        fprintf(fout, '%s\n', Warning_to_user{i});
    end
    fprintf(fout, '\n');
end
if ~isempty(Error_Msg) % reporting errors and exiting
    fprintf(fout, '>  <ALATIS_Errors>\n');
    fprintf(fout, 'unexpected error\n');
    for i=1:length(Error_Msg)
        fprintf(fout, '%s\n', Error_Msg{i});
    end
    fprintf(fout, 'Please contact dashti@wisc.edu to discuss and fix the problem.\n');
    fprintf(fout, '\n');
end
if exist(sprintf('%s/%s', folder_path, compact_sdf_output_name), 'file')
    fprintf(fout, '>  <ALATIS_compact_sdf>\n');
    fprintf(fout, '%s\n\n',compact_sdf_output_name);
end
fclose(fout);

Here = pwd;
cd(folder_path);
Command = sprintf('zip outputs.zip %s display_info', compact_sdf_output_name);
[~, ~] = system(Command);
cd(Here);


