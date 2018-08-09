function Path_to_input_file = conversion_type_format(Path_to_input_file, input_type, project3D_flag, addHydrogen_flag)
global Original_input_atom_names Warning_to_user
if (strcmpi(input_type, 'sdf') || strcmpi(input_type, 'mol')) && str2double(project3D_flag) == 0 && str2double(addHydrogen_flag) == 0
    return
end


temp_mol = sprintf('backup_%s', Path_to_input_file);
system(sprintf('cp %s %s', Path_to_input_file, temp_mol));

if strcmpi(input_type, 'pdb')
    Original_input_atom_names = {};
    fin = fopen(Path_to_input_file, 'r');
    tline = fgetl(fin);
    while ischar(tline)
        if (length(tline)>= 4 && strcmp(tline(1:4), 'ATOM')) || (length(tline) >= 6 && strcmp(tline(1:6), 'HETATM'))
            Original_input_atom_names{end+1} = strrep(tline(13:16), ' ', '');
        end
        tline = fgetl(fin);
    end
    fclose(fin);
end
% set input format
param_input_format = sprintf('-i%s', input_type);

param_outputfeatures = '';
if str2double(addHydrogen_flag) == 1
    param_outputfeatures = ' -h ';
end
if str2double(project3D_flag) == 1
    param_outputfeatures = sprintf('%s --gen3d ', param_outputfeatures);
end

Path_to_input_file = strrep(Path_to_input_file, '.', '_');
Path_to_input_file = sprintf('%s.sdf', Path_to_input_file);
command = sprintf('obabel %s %s -osdf %s -O %s', param_input_format, temp_mol, param_outputfeatures, Path_to_input_file);
system(sprintf('rm -f %s', Path_to_input_file));
[~, b] = system(command);

b = strrep(b, '1 molecule converted', '');
c = regexprep(b,'\s+','');
if ~isempty(c)
    Warning_to_user{end+1} = 'Openbabel warnings: ';
    if length(b) > 215
        text = b(1:215);
        Warning_to_user{end+1} = sprintf('LONG LIST OF WARNINGS<br>\n%s', strrep(text, '\n', '<br>'));
    else
        Warning_to_user{end+1} = b;
    end
end
temp_name = sprintf('temp_%s', Path_to_input_file);
fout = fopen(temp_name, 'w');
fin = fopen(Path_to_input_file, 'r');
tline = fgetl(fin);
flag = 0;
num_atoms = 0;
atom_counter = 0;
wildcard_seen = 0;
while ischar(tline)
    if flag == 1
        num_atoms = num_atoms-1;
        if num_atoms > 1
            atom_counter = atom_counter+1;
            atom_name = tline(32:34);
            if ~isempty(strfind(atom_name, '*'))
                wildcard_seen = 1;
                tline(32:34) = sprintf('%-3s', Original_input_atom_names{atom_counter}(1));
            end
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        num_atoms = str2double(tline(1:3));
        flag = 1;
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
end
fclose(fin);
fclose(fout);
if wildcard_seen == 1
    [~, ~] = system(sprintf('mv %s %s', temp_name, Path_to_input_file));
end
