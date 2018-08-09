function Add_Ch2_SH(Amine, positions, updated_mol_path, updated_mol_temp_path)
fin = fopen(updated_mol_path, 'r');
fout = fopen(updated_mol_temp_path, 'w');
tline = fgetl(fin);
flag = 0;
counter = 0;
while ischar(tline)
    if flag == 1
        for i=1:num_atoms
            counter = counter+1;
            if min(abs(counter - Amine.index)) == 0 %counter == indices(1)
                tline = strrep(tline, 'N', 'C');
            end
            fprintf(fout, '%s\n', tline);
            tline = fgetl(fin);
        end
        S_coord = positions(Amine.index).coord+sum(rand(2, 3));
        HS_coord = S_coord+rand(1, 3)./2;
        fprintf(fout, '%10.4f%10.4f%10.4f S  0  0  0  0  0  0  0  0  0  0  0  0\n', S_coord(1), S_coord(2), S_coord(3));
        fprintf(fout, '%10.4f%10.4f%10.4f H  0  0  0  0  0  0  0  0  0  0  0  0\n', HS_coord(1), HS_coord(2), HS_coord(3));
        for i=1:num_bonds
            fprintf(fout, '%s\n', tline);
            if i<=num_bonds
                tline = fgetl(fin);
            end
        end
        fprintf(fout, '%3d%3d  1  0  0  0  0\n', num_atoms+1, Amine.index);
        fprintf(fout, '%3d%3d  1  0  0  0  0\n', num_atoms+1, num_atoms+2);
        flag = 0;
    end
    if ~isempty(strfind(tline, 'V2000'))
        flag = 1;
        num_atoms = str2double(tline(1:3));
        num_bonds = str2double(tline(4:6));
        tline = sprintf('%3d%3d%s', num_atoms+2, num_bonds+2, tline(7:end));
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
end
fclose(fin);
fclose(fout);
