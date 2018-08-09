function new_inchi = get_new_inchi(array, Methylene, mol_temp_path, folder_path, inchi_temp_path)
global inchi1_Path Error_Msg
% fout = fopen('/home/Hesam/Desktop/temp/indices', 'a');
indices = zeros(length(array), 1);
for i=1:length(indices)
    indices(i) = Methylene(i).proton_indices(array(i));
%     fprintf(fout, '%d\t', indices(i));
end
% fprintf(fout, '\n');
% fclose(fout);
fin = fopen(mol_temp_path, 'r');
mol_path = sprintf('%s/prochiral_temp.mol', folder_path);
fout = fopen(mol_path, 'w');
tline = fgetl(fin);
flag = 0;
counter = 0;
while ischar(tline)
    if flag == 1
        for i=1:num_atoms
            counter = counter+1;
            if min(abs(counter - indices)) == 0 %counter == indices(1)
                tline = strrep(tline, 'H', 'D');
            end
            fprintf(fout, '%s\n', tline);
            tline = fgetl(fin);
        end
        flag = 0;
    end
    if ~isempty(strfind(tline, 'V2000'))
        flag = 1;
        num_atoms = str2double(tline(1:3));
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
end
fclose(fin);
fclose(fout);
[~,cmdout] = system(sprintf('%s %s %s', inchi1_Path, mol_path, inchi_temp_path));
if ~isempty(strfind(cmdout, 'Error'))
    Error_Msg{end+1} = 'Error while generating the standard InChI string. the inchi-1 program has crashed';
    error('inchi-1 crashed')
end
fin = fopen(inchi_temp_path, 'r');
tline = fgetl(fin);
while ischar(tline)
    if ~isempty(strfind(tline, 'InChI='))
        new_inchi = tline;
        break
    end
    tline = fgetl(fin);
end
fclose(fin);

