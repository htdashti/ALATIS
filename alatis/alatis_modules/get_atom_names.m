function [atom_names, atom_labels] = get_atom_names(updated_mol_name)
global Error_Msg
[atom_names, matrix, ~] = convert_mol_to_detailed_graph(updated_mol_name);
matrix = make_symmetric(matrix);
Letters = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
letter_iter1 = 0;
letter_iter2 = 1;
atom_labels = cell(length(atom_names), 1);
for i=1:size(matrix, 1)
    if i > 99
        letter_iter1 = letter_iter1+1;
        if letter_iter1 > length(Letters)
            letter_iter2 = letter_iter2+1;
            letter_iter1 = 1;
        end
        if letter_iter2 > length(Letters)
            Error_Msg{end+1} = 'Unexpected number of atoms!';
            error('ran out of letters to label the atoms');
        end
        heavy_atom_index_str = sprintf('%s%s', Letters{letter_iter2}, Letters{letter_iter1});
    else
        heavy_atom_index_str = sprintf('%02d', i);
    end
    if ~strcmp(atom_names{i}, 'H') % heavy atoms
        atom_labels{i} = sprintf('%s%s', atom_names{i}, heavy_atom_index_str); % heavy atom name (1:2) chars + 02 digit index
        indices = find(matrix(i, :) == 1);
        H_counter = 0;
        for j=1:length(indices)
            index = indices(j);
            if strcmp(atom_names{index}, 'H')
                H_counter = H_counter+1;
            end
        end
        H_index = 0;
        for j=1:length(indices)
            index = indices(j);
            if strcmp(atom_names{index}, 'H')
                if H_counter == 1
                    atom_labels{index} = sprintf('H%s', heavy_atom_index_str);
                else
                    H_index = H_index+1;
                    atom_labels{index} = sprintf('H%s%d', heavy_atom_index_str, H_index);
%                     if H_index > length(Letters)
%                         atom_labels{index} = sprintf('H%d%d', i, H_index);
%                     else
%                         atom_labels{index} = sprintf('H%d%s', i, Letters{H_index});
%                     end
                end
            end
        end
    end
end
