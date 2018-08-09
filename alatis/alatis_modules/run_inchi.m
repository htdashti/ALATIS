% runs inchi-1 and parses the inchi string and the corrsponding auxinfo line
function [new_inchi, aux_info] = run_inchi(mol_path, inchi_temp_path)
global inchi1_Path Error_Msg

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
    end
    if ~isempty(strfind(tline, 'AuxInfo='))
        aux_info = tline;
    end
    tline = fgetl(fin);
end
fclose(fin);
