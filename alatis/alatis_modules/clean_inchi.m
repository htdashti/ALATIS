% this function parse the output files of the inchi-1 program to extract
% inchi strings and their corresponding auxinfo
function [inchi, auxInfo_line] = clean_inchi(path_in, path_out, path_out_2, folder_path)
global mol_f_name
inchi = '';
fout_complete = fopen(path_out_2, 'w');
fout = fopen(path_out, 'w');
fin = fopen(path_in, 'r');
tline = fgetl(fin);
while ischar(tline)
    if ~isempty(strfind(tline, 'InChI='))
        inchi = tline;
        fprintf(fout, '%s\n', tline);
        fprintf(fout_complete, '%s\n', tline);
    end
    if ~isempty(strfind(tline, 'AuxInfo='))
        fprintf(fout_complete, '%s\n', tline);
        auxInfo_line = tline;
    end
    tline = fgetl(fin);
end
fclose(fin);
fclose(fout);
fclose(fout_complete);
system(sprintf('rm -f %s/%s.log', folder_path, mol_f_name));
system(sprintf('rm -f %s/%s.prb', folder_path, mol_f_name));
system(sprintf('rm -f %s', path_in));

