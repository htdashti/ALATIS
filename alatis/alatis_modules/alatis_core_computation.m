function outputs = alatis_core_computation(folder_path, fname)
global Error_Msg inchi1_Path Warning_to_user mol_f_name updated_mol_name Split_mol_names failed_methylene_check
Error_Msg = {};
Split_mol_names = {};
failed_methylene_check = 0;

% checking compatibility of the input file
try
    mol_path = PreCheck_of_inputfile(folder_path, mol_f_name);
catch
    Error_Msg{end+1} = 'failed during preprocessing';
    error('preprocessing failed');
end

updated_mol_name = sprintf('alatis_output_%s', strrep(fname, '/', ''));
updated_mol_path = sprintf('%s/alatis_output_%s', folder_path, strrep(fname, '/', ''));
updated_mol_temp_path = sprintf('%s/%s_temp_output.mol', folder_path, strrep(fname, '/', ''));
inchi_temp_path  = sprintf('%s/inchi_temp.inchi', folder_path);
inchi_complete_path  = sprintf('%s/inchi_complete.inchi', folder_path);
inchi_inchi_path = sprintf('%s/inchi.inchi', folder_path);



try
    [mol_atom_names, ~, mol_protons_bonds, Three_D_flag] = convert_mol_heavy_atoms_to_graph(mol_path);
    if isempty(mol_protons_bonds) && nnz(strcmpi(mol_atom_names, 'H')) ~= 0
        Error_Msg{end+1} = 'The input file does not contain any bond or connection for hydrogen atoms';
        error('parsing input file')
    end
catch
    Error_Msg{end+1} = 'error while parsing the input file!';
    error('parsing input file')
end

% reporting error and aborting
if ~isempty(Error_Msg) && strcmp(Error_Msg{end}, 'no heavy atoms found!')
    system(sprintf('cp %s/%s %s/%s', folder_path, mol_f_name, folder_path, updated_mol_name));
    Error_Msg = [];
    Warning_to_user{end+1} = 'There is no heavy atom in the input structure file! ALATIS has been aborted!';
    updated_prev_Map = 1:length(mol_atom_names);
    outputs = fill_outputs(folder_path, mol_atom_names, updated_prev_Map, mol_f_name, inchi_complete_path, Three_D_flag, updated_mol_path);
    clean_folder(folder_path, fname);
    return
end
    
% run inchi-1
[~,cmdout] = system(sprintf('%s %s %s', inchi1_Path, mol_path, inchi_temp_path));
% check inchi-1 outputs for error
if ~isempty(strfind(cmdout, 'Error'))
    content = strsplit(cmdout, '\n');
    for i=1:length(content)
        if ~isempty(strfind(content{i}, 'Error'))
            Error_Msg{end+1} = content{i};
            break
        end
    end
    Error_Msg{end+1} = 'Error while generating the standard InChI string. the inchi-1 program has crashed';
    error('inchi-1 crashed')
end
if ~isempty(strfind(cmdout, 'Warning'))
    content = strsplit(cmdout, '\n');
    for i=1:length(content)
        if ~isempty(strfind(content{i}, 'Warning'))
            Warning_to_user{end+1} = 'The InChI-1 program has generated the following warning. Check the structure file for possible problems:';
            Warning_to_user{end+1} = content{i};
            break
        end
    end
end
% parsing inchi-1 output
try
    [inchi, auxInfo_line] = clean_inchi(inchi_temp_path, inchi_inchi_path, inchi_complete_path, folder_path);
catch
    Error_Msg{end+1} = 'Could not run the inchi-1 program on the input structure file';
    error('inchi-1 crashed')
end
% if there is a '?' in inchi string, it means there was a problem in the
% structure file that inchi-1 could not identify the stereo of the atoms
% Aborting
if ~isempty(strfind(inchi, '?'))
    Error_Msg{end+1} = 'There is a "?" in the InChI string. This usually happens when a 2D mol file is loaded. If this is not the case, please contact us: dashti@nmrfam.wisc.edu';
    error('?')
end

try
    [inchi_names, ~] = convert_inchi_heavy_atoms_to_graph(inchi);
    % checking for errors in inchi atom names
    if ~isempty(Error_Msg)
        if strcmp(Error_Msg{1}, 'short inchi')
            Error_Msg = [];
            system(sprintf('cp %s/%s %s/%s', folder_path, mol_f_name, folder_path, updated_mol_name));
            Warning_to_user{end+1} = 'The InChI is not complete, in terms of connectivity between heavy atoms and their attached hydrogens';
            updated_prev_Map = 1:length(mol_atom_names);
            outputs = fill_outputs(folder_path, mol_atom_names, updated_prev_Map, mol_f_name, inchi_complete_path, Three_D_flag, updated_mol_path);
            clean_folder(folder_path, fname)
            return
        end
        error('convert inchi to graph')
    end
    if isempty(inchi_names)
        Error_Msg{end+1} = 'No heavy atom found in InChI string';
        error('no heavy atom');
    end
    Map = get_map(auxInfo_line);
    % check map between indices is correct
    if length(Map) ~= length(inchi_names)
        atoms_added_indices = Map > length(mol_atom_names);
        Map(atoms_added_indices) = [];
        if length(Map) ~= length(inchi_names)
            Error_Msg{end+1} = 'The structure file is not compatible with the inchi-1 program. Most probably there are single hydrogen atoms in the structure file.';
            error('no heavy atom');
        end
    end
catch
    Error_Msg{end+1} = 'error while parsing InChI string!';
    error('parsing InChI');
end

% atom types should be the same
for i=1:length(Map)
    if ~strcmpi(inchi_names{i}, mol_atom_names{Map(i)})
        Error_Msg{end+1} = 'There was an error while constructing graphs of heavy atoms.';
        error('mismatch')
    end
end
% appending protons to the map of heavy atoms
try
    if ~isempty(mol_protons_bonds)
        Map = Extend_Map(Map, mol_protons_bonds);
    end
catch
    Error_Msg{end+1} = 'could not incorporate protons to the map';
    error('adding protons')
end
% floating for floating protons (or these are unbounded protons):
try 
    if length(Map) ~= length(mol_atom_names)
        array = 1:length(mol_atom_names);
        array(Map) = [];
        Map = [Map, array];
    end
catch
    Error_Msg{end+1} = 'There are unbounded protons. error while adding these protons';
    error('floating protons');
end
% updaing structure file with the new map
try
    update_mol_file(folder_path, mol_path, updated_mol_temp_path, Map);
catch ME
    Error_Msg{end+1} = 'could not update the labels in the input file';
    error('update_mol_file');
end
% next additional proton labeling
% consideing prochiral centers
try
    if Three_D_flag == 1
        [updated_prev_Map, new_map] = consider_prochiral_protons_II(folder_path, updated_mol_temp_path, inchi, inchi_temp_path, Map);
    else
        updated_prev_Map = Map;
        new_map = 1:length(Map);
    end
catch
    Error_Msg{end+1} = 'could not process the prochiral centers';
    error('update_mol_file');
end

% update mol file based on the new mao from prochiral centers
try
    update_mol_file(folder_path, updated_mol_temp_path, updated_mol_path, new_map);
catch ME
    Error_Msg{end+1} = 'could not update the labels in the input file';
    error('update_mol_file');
end

% consider atoms at NH2, CH3, D/T centers
try
    updated_prev_Map = consider_NH2(updated_mol_path, updated_prev_Map, updated_mol_temp_path, inchi_temp_path, folder_path);
    updated_prev_Map = consider_CH3(updated_mol_path, updated_prev_Map, updated_mol_temp_path, folder_path);
    updated_prev_Map = consider_D_T(updated_mol_path, updated_prev_Map, updated_mol_temp_path, folder_path);
catch
    Error_Msg{end+1} = 'could not process NH2, CH3, or D/T atoms';
    error('error_labeling')
end

try
    [~,cmdout] = system(sprintf('%s %s %s', inchi1_Path, updated_mol_path, inchi_temp_path));
    if ~isempty(strfind(cmdout, 'Error'))
        Error_Msg{end+1} = 'Error while generating the standard InChI string. the inchi-1 program has crashed';
        error('inchi-1 crashed')
    end
    clean_inchi(inchi_temp_path, inchi_inchi_path, inchi_complete_path, folder_path);
catch
    Error_Msg{end+1} = 'error while parsing InChI string';
    error('parsing InChI');
end
try
    % check for symmetric heavy atoms
    if exist('./inchi_complete.inchi', 'file')
        fin = fopen('./inchi_complete.inchi', 'r');
        fgetl(fin);
        aux = fgetl(fin);
        content = strsplit(aux, '/');
        content = strrep(content{3}, 'N:', '');
        content = strsplit(content, ',');
        array = [];
        for i=1:length(content)
            if ~isempty(strfind(content{i}, ';'))
                cont_mixture = strsplit(content{i}, ';');
                array = [array;str2double(cont_mixture{1})];
                array = [array;str2double(cont_mixture{2})];
            else
                array = [array;str2double(content{i})];
            end
        end
        symm = false;
        for i=1:length(array)
            if array(i) ~= i
                symm = true;
                break
            end
        end
        fclose(fin);
        if symm
            Warning_to_user{end+1} = 'InChI identified symmetric compound/fragment. This could cause inconsistency in atom indices';
        end
    end
catch
    Warning_to_user{end+1} = 'Could not check symmetricity!';
end

% considering counterions
updated_prev_Map = process_mixtures(updated_prev_Map, inchi_inchi_path, updated_mol_path, folder_path, updated_mol_temp_path);

% preparing outputs
% to consider before 'M END' tags
finalize_mol_file(updated_mol_path, updated_prev_Map);


outputs = fill_outputs(folder_path, mol_atom_names, updated_prev_Map, mol_f_name, inchi_complete_path, Three_D_flag, updated_mol_path);

clean_folder(folder_path, fname);


function outputs = fill_outputs(folder_path, mol_atom_names, updated_prev_Map, mol_f_name, inchi_complete_path, Three_D_flag, updated_mol_path)
outputs.folder_path = folder_path;
outputs.mol_atom_names = mol_atom_names;
outputs.updated_prev_Map = updated_prev_Map;
outputs.mol_f_name = mol_f_name;
outputs.inchi_complete_path = inchi_complete_path;
outputs.Three_D_flag =Three_D_flag;
outputs.updated_mol_path = updated_mol_path;
    









