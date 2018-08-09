function [atom_names, matrix, positions] = convert_mol_to_detailed_graph(mol_path)
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
loop_starts = 0;
while ischar(tline)
    if loop_starts == 1
        for iter = 1:num_atoms
            %content = strsplit(tline);
            counter = counter+1;
            %'xxxxx.xxxxyyyyy.yyyyzzzzz.zzzz aaa'
            atom_names{counter} = strrep(tline(32:34), ' ', ''); 
            positions(counter).coord = [str2double(tline(1:10)), str2double(tline(11:20)), str2double(tline(21:30))];
%             if isempty(content{1})
%                 atom_names{counter} = strrep(tline(32:34), ' ', ''); %content{5}; %sprintf('%s%d', content{5}, counter);
%                 positions(counter).coord = [str2double(content{2}), str2double(content{3}), str2double(content{4})];
%             else
%                 atom_names{counter} = content{4}; %sprintf('%s%d', content{4}, counter);
%                 positions(counter).coord = [str2double(content{1}), str2double(content{2}), str2double(content{3})];
%             end
            if iter~= num_atoms
                tline= fgetl(fin);
            end
        end
        for iter =1:num_edges
            tline = fgetl(fin);
            from = str2double(tline(1:3));
            to = str2double(tline(4:6));
            matrix(from, to) = 1;
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        num_atoms = str2double(tline(1:3));
        num_edges = str2double(tline(4:6));
        matrix = zeros(num_atoms);
        atom_names = cell(num_atoms, 1);
        loop_starts = 1;
        counter = 0;
    end
    tline = fgetl(fin);
    if ~isempty(strfind(tline, 'M ')) ||(length(tline) >= 6 && strcmp(tline(4:6), 'END'))% ~isempty(strfind(tline, 'END'))
        break
    end
end
fclose(fin);


