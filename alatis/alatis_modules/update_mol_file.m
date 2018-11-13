% this function gets an input structure (folder_path, mol_path) and creates
% an updated structure file (updated_mol_path) according to the map
function update_mol_file(folder_path, mol_path, updated_mol_path, Map)
global Tail compound_name

fout = fopen(updated_mol_path, 'w');
fprintf(fout, '%s\n', compound_name);
fprintf(fout, '    alatis_output_mol\n\n');
[Begin, End, atoms, edges] = parse_input_mol(mol_path);

fprintf(fout, '%s\n', Begin);
% updating atom indices according to Map
Atoms = cell(length(atoms), 1);
for i=1:length(atoms)
    Atoms{i} = atoms{Map(i)};
end
% wrting atoms
for i=1:length(Atoms)
    fprintf(fout, '%s\n', Atoms{i});
end

% updating edges indices according to Map
Edges = cell(length(edges), 1);
new_indices = [];
for i=1:length(edges)
    Edges{i} = [get_index(Map, edges(i).from), get_index(Map, edges(i).to), edges(i).rest];
    new_indices = [new_indices; get_index(Map, edges(i).from), get_index(Map, edges(i).to)];
end
% writing edges
[~, index] = sortrows(new_indices);
for iter=1:length(Edges)
    i = index(iter);
    fprintf(fout, '%3d%3d%3d%3d%3d%3d%3d\n', Edges{i}(1), Edges{i}(2), Edges{i}(3), Edges{i}(4), Edges{i}(5), Edges{i}(6), Edges{i}(7));
end

% updating and writing out the RAD, CHG, ISO, SBL, SAL tags at the end
for i=1:length(End)
    if ~isempty(strfind(End{i}, 'CHG')) || ~isempty(strfind(End{i}, 'RAD')) || ~isempty(strfind(End{i}, 'ISO'))
        STR = End{i};
        content = strsplit(STR);
        list = [];
        j = 4;
        while j < length(content)
            new_index=get_index(Map, str2double(content{j}));
            charge_code = str2double(content{j+1});
            list = [list;[new_index, charge_code]];
            j = j+2;
        end
        if ~isempty(strfind(End{i}, 'CHG'))
            fprintf(fout, 'M  CHG%3d', str2double(content{3}));
        end
        if ~isempty(strfind(End{i}, 'RAD'))
            fprintf(fout, 'M  RAD%3d', str2double(content{3}));
        end
        if ~isempty(strfind(End{i}, 'ISO'))
            fprintf(fout, 'M  ISO%3d', str2double(content{3}));
        end
        for j=1:size(list, 1)
            fprintf(fout, '%4d%4d', list(j, 1), list(j, 2));
        end
        fprintf(fout, '\n');
    else
        if ~isempty(strfind(End{i}, 'SAL')) || ~isempty(strfind(End{i}, 'SBL'))
            line = End{i};
            pre = line(1:14);
            j = 15;
            list = [];
            while j < length(line)
                list = [list; get_index(Map, str2double(line(j:j+2)))];
                j = j+4;
            end
            fprintf(fout, '%s', pre);
            for j=1:length(list)
                fprintf(fout, '%3d ', list(j));
            end
            fprintf(fout, '\n');
        else
            fprintf(fout, '%s\n', End{i});
        end
    end
end
% adding Tail (populating in PreCheck_of_inputfile.m). If it is a pubchecm
% sdf, BMRB wants to update the inchi in tail:
if ~isempty(Tail)
    content = strsplit(Tail, '\n', 'CollapseDelimiters',false);
    for i=1:length(content)
        if ~isempty(strfind(content{i}, '<PUBCHEM_IUPAC_INCHI>'))
            try
                fin = fopen(sprintf('%s/inchi.inchi', folder_path), 'r');
                inchi = fgetl(fin);
                fclose(fin);
            catch
                inchi = content{i+1};
            end
            content{i+1} = inchi;
        end
    end
    for i=1:length(content)
        fprintf(fout, '%s\n', content{i});
    end
end
fclose(fout);

