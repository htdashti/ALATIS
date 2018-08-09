function [new_inchi, aux_info] = get_Ch2_SH_new_inchi(Amine, updated_mol_temp_path, inchi_temp_path, folder_path)
fin = fopen(updated_mol_temp_path, 'r');
mol_path = sprintf('%s/temp.mol', folder_path);
fout = fopen(mol_path, 'w');
tline = fgetl(fin);
flag = 0;
counter = 0;
while ischar(tline)
    if flag == 1
        for i=1:num_atoms
            counter = counter+1;
            if min(abs(counter - Amine.proton_indices(1))) == 0 %counter == indices(1)
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
[new_inchi, aux_info] = run_inchi(mol_path, inchi_temp_path);
