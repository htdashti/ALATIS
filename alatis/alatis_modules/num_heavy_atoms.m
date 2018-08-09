function num_atoms = num_heavy_atoms(inchi)
global Error_Msg

num_atoms =  0;
content = strsplit(inchi, '/');
Atoms_seq = content{2};

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
