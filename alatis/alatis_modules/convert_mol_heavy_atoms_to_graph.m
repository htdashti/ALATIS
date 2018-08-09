% this function reports atom names, connectivity matrix, number of proton
% bonds and also reports whether the input file is a 3 file or not.
function [atom_names, matrix, protons_bonds, Three_D_flag] = convert_mol_heavy_atoms_to_graph(mol_path)
global Error_Msg
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
loop_starts = 0;
used_atoms_indices = [];
tline_counter =0;
protons_bonds = [];
heavy_atom_counter = 0;
Three_D_flag = 0;
while ischar(tline)
    if loop_starts == 1
        for i=1:num_atoms % positions
            tline_counter = tline_counter+1;
            counter = counter+1;
            atom_names{counter} = strrep(tline(32:34), ' ', ''); 
            if str2double(tline(21:30)) ~= 0 % if there is at least one non-zero z-coordinate, it is a 3D structure
                Three_D_flag = 1;
            end
            if ~strcmp(atom_names{counter}, 'H') && ~strcmp(atom_names{counter}, 'D') && ~strcmp(atom_names{counter}, 'T')
                heavy_atom_counter = heavy_atom_counter+1;
                used_atoms_indices = [used_atoms_indices;tline_counter];
            end
            if i ~= num_atoms
                tline = fgetl(fin);
            end
        end
        if isempty(used_atoms_indices) % no heavy atoms detected
            Error_Msg{end+1} = 'no heavy atoms found!';
            return
        end
        for i=1:num_bonds
            tline = fgetl(fin);
            if (length(tline) > 3 && isnan(str2double(tline(1:3))))
                break
            end
            from = str2double(tline(1:3));
            to = str2double(tline(4:6));
            if min(abs(used_atoms_indices-from)) == 0 && min(abs(used_atoms_indices-to)) == 0 % connectivity between heavy atoms
                matrix(from, to) = 1;
            else 
                if min(abs(used_atoms_indices-from)) == 0 % from is a heavy atom but is connected to a proton (to)
                    protons_bonds = [protons_bonds;[from, to]];
                end
                if min(abs(used_atoms_indices-to)) == 0 % to is a heavy atom but is connected to a proton (from)
                    protons_bonds = [protons_bonds;[to, from]];
                end
            end
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        num_atoms = str2double(tline(1:3));
        num_bonds = str2double(tline(4:6));
        matrix = zeros(num_atoms);
        atom_names = cell(num_atoms, 1);
        loop_starts = 1;
        counter = 0;
    end
    tline = fgetl(fin);
    if mol_reached_a_stop_points(tline)
        break
    end
end
fclose(fin);
remove_rows = false(size(matrix, 1), 1);
for i=1:size(matrix, 1)
    if min(abs(used_atoms_indices-i)) ~= 0
        remove_rows(i) = true;
    end
end
matrix(:, remove_rows) = [];
matrix(remove_rows, :) = [];
