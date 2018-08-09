% this function is to extract the tail of sdf files and get parameters
% defined before M END in a mol structure. In addition this function checks
% atom names to be compatible with inchi-1, and checks the number of
% compounds in the input file that must be one.
function prechecked_mol = PreCheck_of_inputfile(folder_path, mol_f_name)
global Error_Msg Tail compound_name PRE_M_block

mol_path = sprintf('%s/%s', folder_path, mol_f_name);
prechecked_mol = sprintf('%s/prechecked_%s', folder_path, mol_f_name);

fin = fopen(mol_path, 'r');
tline = fgetl(fin);
compound_name = tline;
prepared_for_input = '';
Tail = '';
PRE_M_block = '';
loop_starts = 0;
Compound_counter = 0;

while ischar(tline)
    if loop_starts == -2
        if length(tline) >= 3 && strcmp(tline(1:3), 'M  ')
            
        else
            PRE_M_block = sprintf('%s\n%s', PRE_M_block, tline);
            tline = fgetl(fin);
            continue
        end
    end
    if length(tline) >= 3 && strcmp(tline(1:3), 'A  ') || length(tline) >= 3 && strcmp(tline(1:3), 'V  ') || length(tline) >= 3 && strcmp(tline(1:3), 'G  ')
        loop_starts = -2;
        PRE_M_block = tline;
        tline = fgetl(fin);
        continue
    end
    if loop_starts == -1
        if isempty(strtrim(tline))
            Tail = sprintf('%s\n', Tail);
        else
            if isempty(Tail)
                Tail = sprintf('%s\n', tline);
            else
                Tail = sprintf('%s%s\n', Tail, tline);
            end
                
            
        end
    end
    if ~isempty(strfind(tline, 'M ')) || (length(tline) >= 6 && strcmp(tline(4:6), 'END')) 
        loop_starts= 0;
    end
    if length(tline) >= 6 && strcmp(tline(4:6), 'END') 
        loop_starts= -1;
    end
    if loop_starts == 1
        if Num_atoms > 0
            Num_atoms = Num_atoms-1;
            atom_name = strrep(tline(32:34), ' ', '');
            if length(atom_name) > 1
                new_atom_name = atom_name;
                new_atom_name(2) = lower(new_atom_name(2));
                tline = strrep(tline, atom_name, new_atom_name);
            end
            if length(atom_name) > 2
                Error_Msg{end+1} = sprintf('unknown atom "%s". Atom names should have at most 2 letters', atom_name);
                error('unaccepted letters');
            end
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        loop_starts = 1;
        Compound_counter = Compound_counter +1;
        Num_atoms = str2double(tline(1:3));
        Num_bonds = str2double(tline(4:6));
    end

    prepared_for_input = sprintf('%s%s\n', prepared_for_input, tline);
    tline = fgetl(fin);
end

fclose(fin);
fout = fopen(prechecked_mol, 'w');
fprintf(fout, '%s', prepared_for_input);
fclose(fout);
if Compound_counter == 0
    Error_Msg{end+1} = 'The input file does not contain a recognizable structure! Follow mol, sdf, or other acceptable formats';
    error('Unexpected number of compounds');
end
if Compound_counter > 1
    Error_Msg{end+1} = 'The input file contains multiple structures; for batch processing of multiple compounds in a structure file please contact us.';
    error('Unexpected number of compounds');
end
