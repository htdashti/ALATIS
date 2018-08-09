% this function parse an inchi string and pulls out atom connectivities
function [atom_names, matrix] = convert_inchi_heavy_atoms_to_graph(inchi)
global Error_Msg
content = strsplit(inchi,'/');
if length(content) < 3
    Error_Msg{end+1} = 'short inchi';% 'The InChI string is not complete';
    Error_Msg{end+1} = inchi;
    Error_Msg{end+1} = 'The structure file is not compatible with the inchi-1 program';
    atom_names ={};
    matrix = [];
    return
end

if ~isempty(strfind(content{2}, '.')) || ~isempty(strfind(content{3}, ';')) || ~isempty(strfind(content{3}, '*'))
    [splited_inchis, ~] = split_inchi(inchi);
    atom_names = {};
    matrix = [];
    for i=1:length(splited_inchis)
        [c_atom_names, c_matrix] = call_parse_inchi(splited_inchis{i});
        atom_names = [atom_names; c_atom_names];
        new_matrix = zeros(size(matrix, 1)+size(c_matrix, 1));
        new_matrix(1:size(matrix, 1), 1:size(matrix, 1)) = matrix;
        new_matrix(size(matrix, 1)+1:end, size(matrix, 1)+1:end) = c_matrix;
        matrix = new_matrix;
    end
else
    [atom_names, matrix] = call_parse_inchi(inchi);
end
