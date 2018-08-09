function [atom_names, matrix] = call_parse_inchi(inchi)
global Error_Msg
Inchi_split = strsplit(inchi,'/', 'CollapseDelimiters', false);
if length(Inchi_split) < 3
    Error_Msg{end+1} = 'The InChi string is not complete';
    Error_Msg{end+1} = inchi;
    return
end
% parse atoms
Atoms_seq = Inchi_split{2};
Atoms_seq = strsplit(Atoms_seq, '.');
Atoms_seq = Atoms_seq{1};
%Atoms_cell = cell(length(Atoms_seq), 1);
Atom_seq_counter = 0;
for i=1:length(Atoms_seq)
   % Atoms_seq(i)
    if isstrprop(Atoms_seq(i), 'lower')
        if i == 1
            Error_Msg{end+1} = sprintf('the atom %s was not recognized!', Atoms_seq(i));
            return
        end
        Atoms_cell{Atom_seq_counter} = sprintf('%s%s', Atoms_cell{Atom_seq_counter}, Atoms_seq(i));
    else
        Atom_seq_counter = Atom_seq_counter+1;
        Atoms_cell{Atom_seq_counter} = Atoms_seq(i);
    end
end
%[c_list, n_list] = split_char_vs_nums(Atoms_cell);
c_list = {};
n_list =[];

merged = merge_split_char_vs_nums(Atoms_cell);
i = 1;
while i <= length(merged)
    if isnan(str2double(merged{i}))
        if i+1> length(merged) || ~isnumeric(merged{i+1})
            if strcmpi(merged{i}, 'H') || strcmpi(merged{i}, 'D')
                i = i+1;
                continue
            end
            c_list{end+1} = merged{i};
            n_list = [n_list; 1];
            i = i+1;
        else
            if strcmpi(merged{i}, 'H') || strcmpi(merged{i}, 'D')
                i = i+2;
                continue
            end
            c_list{end+1} = merged{i};
            n_list = [n_list; merged{i+1}];
            i = i+2;
        end
    end
end
num_atoms = sum(n_list);

matrix = zeros(num_atoms);
if isempty(matrix)
    atom_names = [];
    return
end
Atoms_dictionary = [];
Atoms_counter =1;
for i=1:length(c_list)
    if strcmp(c_list(i), 'H')
        continue;
    end
    for j=1:n_list(i)
        Atoms_dictionary{Atoms_counter, 1} = c_list{i};
        Atoms_dictionary{Atoms_counter, 2} = Atoms_counter;
        Atoms_counter = Atoms_counter+1;
    end
end

% heavy atom connectivities
if ~isempty(Inchi_split{3})
    heavyatom_seq = Inchi_split{3};
    %heavyatom_seq = heavyatom_seq(2:end);
    if ~isempty(heavyatom_seq(2:end)) && strcmp(heavyatom_seq(1), 'c')
        heavyatom_seq = heavyatom_seq(2:end);
        content = strsplit(heavyatom_seq, ';');
        heavyatom_seq = content{1};
        heavyatom_seq_cell = cell(length(heavyatom_seq), 1);
        for i=1:length(heavyatom_seq)
            heavyatom_seq_cell{i} = heavyatom_seq(i);
        end
        [c_list, n_list] = split_char_vs_nums(heavyatom_seq_cell);
        for i=2:length(n_list)
            if strcmp(c_list{i-1}, '-')
                %fprintf('%d-%d\n', n_list(i-1), n_list(i))
                matrix(n_list(i-1), n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, ')')
                [index, error_msg] = find_root_index_pClose(n_list, c_list, i-1);
                if ~isempty(error_msg)
                    Error_Msg{end+1} = error_msg;
                    return
                end
                %fprintf('%d-%d\n', index, n_list(i))
                matrix(index, n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, '(')
                %fprintf('%d-%d\n', n_list(i-1), n_list(i))
                matrix(n_list(i-1), n_list(i)) = 1;
            end
            if strcmp(c_list{i-1}, ',')
                [index, error_msg] = find_root_index_pClose(n_list, c_list, i-1);
                if ~isempty(error_msg)
                    Error_Msg{end+1} = error_msg;
                    %errordlg(error_msg)
                    return
                end
                %fprintf('%d-%d\n', index, n_list(i))
                matrix(index, n_list(i)) = 1;
            end
        end
    end
end

atom_names = Atoms_dictionary(:, 1);
