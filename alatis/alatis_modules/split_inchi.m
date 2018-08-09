function [inchis, mirror_list] = split_inchi(inchi)
[heavy_atom_list, connections_list, protons_list, stero_list, mirror_list] = get_inchi_components(inchi);

Len = max([length(heavy_atom_list), length(connections_list), length(protons_list)]);
inchis = cell(Len, 1);
if ~isempty(stero_list)
    for index=1:Len
        inchis{index} = sprintf('InChI=1S/%s/c%s/h%s/t%s', heavy_atom_list{index}, connections_list{index}, protons_list{index}, stero_list{index});
    end
else
    for index=1:Len
        inchis{index} = sprintf('InChI=1S/%s/c%s/h%s', heavy_atom_list{index}, connections_list{index}, protons_list{index});
    end
end


