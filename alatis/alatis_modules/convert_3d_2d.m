function convert_3d_2d(mol_path)
global MolConvert_path

mol_path = sprintf('./%s', mol_path);
MolConvert_path = '/raid/marvin/MarvinBeans/bin/molconvert';
%MolConvert_path = '/opt/chemaxon/marvinsuite/bin/molconvert';


[pathstr,name,ext] = fileparts(mol_path);
twoD_fpath = sprintf('%s/2D_%s%s', pathstr,name,ext);
[~, ~] = system(sprintf('%s -2:2 mol %s -o %s', MolConvert_path, mol_path, twoD_fpath));
Process_a_file(twoD_fpath)
[~, ~] = system(sprintf('mv %s/temp.svg %s/gissmo.svg', pathstr, pathstr));
[~, ~] = system(sprintf('convert %s/gissmo.svg %s/gissmo.jpg', pathstr, pathstr));

function Process_a_file(mol_path)
[pathstr,name,ext] = fileparts(mol_path);
fname = sprintf('%s%s', name,ext);
[atom_names, connectivities, positions] = convert_mol_to_detailed_graph(mol_path);
edges = get_edges(atom_names, connectivities, positions);
Table = shrink_edges(edges);
shrinked_path = generate_shrinked_mol_file(mol_path, pathstr, fname, Table, atom_names);
%generate_a_graphviz_figure(shrinked_path, pathstr, fname);
generate_mol_files(mol_path, pathstr, fname, Table, atom_names)
generate_python_script_for_mol3d_2d(atom_names);
[~, ~] = system('python parse_svg.py');
%[a, b] = system('python parse_svg.py')




function generate_mol_files(mol_path, pathstr, fname, Table, atom_names)
global MolConvert_path

[~, matrix, ~] = convert_mol_to_detailed_graph(mol_path);
num_edges = nnz(matrix);

shrinked_path = sprintf('%s/shrinked_renumbered_%s', pathstr, fname);
fout = fopen(shrinked_path, 'w');
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
flag = 0;
line_counter = 1;
atom_counter = 0;
edge_flag = 0;
edge_counter = 0;
while ischar(tline)
    if edge_flag
        edge_counter = edge_counter+1;
        if edge_counter <= num_edges
            tline = tline(1:10);
        end
    end
    tline = strrep(tline, '\n', '');
    if line_counter == 2
        fprintf(fout, 'scaled_Marvin\n');
        tline = fgetl(fin);
        line_counter = line_counter+1;
        continue;
    end
    if flag == 1
        atom_counter = atom_counter + 1;
        if ~isempty(strfind(tline, 'H'))
            tline(32:34) = sprintf('%-3d', atom_counter);
            remain = tline(31:end);
            index = find(Table(:, 1) == atom_counter);
            x = sprintf('%10.4f', Table(index, 2));
            y = sprintf('%10.4f', Table(index, 3));
            z = sprintf('%10.4f', Table(index, 4));
            tline = sprintf('%s%s%s%s', x, y, z, remain);
        else
            %if isempty(strfind(tline, 'C')) && length(sprintf('%s%d', atom_names{atom_counter}, atom_counter)) == length(tline(32:34))
            %    tline(32:34) = sprintf('%3s', sprintf('%s%d', atom_names{atom_counter}, atom_counter));
            %else
                tline(32:34) = sprintf('%3s', sprintf('%d', atom_counter));
            %end
        end
        if atom_counter == length(atom_names)
            flag = 0;
            edge_flag = 1;
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        flag = 1;
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
    line_counter = line_counter+1;
end
fclose(fin);
fclose(fout);
[~, ~] = system(sprintf('%s "svg:w1000" %s -o mol.svg', MolConvert_path, shrinked_path));



function shrinked_path = generate_shrinked_mol_file(mol_path, pathstr, fname, Table, atom_names)
shrinked_path = sprintf('%s/shrinked_%s', pathstr, fname);
fout = fopen(shrinked_path, 'w');
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
flag = 0;
line_counter = 1;
atom_counter = 0;
while ischar(tline)
    tline = strrep(tline, '\n', '');
    if line_counter == 2
        fprintf(fout, 'scaled_Marvin\n');
        tline = fgetl(fin);
        line_counter = line_counter+1;
        continue;
    end
    if flag == 1
        atom_counter = atom_counter + 1;
        if ~isempty(strfind(tline, 'H'))
            %tline(32:34) = sprintf('%-3d', atom_counter);
            remain = tline(31:end);
            index = find(Table(:, 1) == atom_counter);
            x = sprintf('%10.4f', Table(index, 2));
            y = sprintf('%10.4f', Table(index, 3));
            z = sprintf('%10.4f', Table(index, 4));
            tline = sprintf('%s%s%s%s', x, y, z, remain);
        end
        if atom_counter == length(atom_names)
            flag = 0;
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        flag = 1;
    end
    fprintf(fout, '%s\n', tline);
    tline = fgetl(fin);
    line_counter = line_counter+1;
end
fclose(fin);
fclose(fout);


function Table = shrink_edges(edges)
Table = zeros(length(edges), 4);
for i=1:length(edges)
    if ~isempty(strfind(edges(i).from.atom, 'H'))
        to_be_shrinked = 'from';
        base = 'to';
    else
        to_be_shrinked = 'to';
        base = 'from';
    end
    delta = edges(i).(to_be_shrinked).coord-edges(i).(base).coord;
    
    Table(i, 1) = edges(i).(to_be_shrinked).atom_index;
    Table(i, 2:end) = edges(i).(base).coord+.5.*delta;
end

function edges = get_edges(atom_names, connectivities, positions)
edges = [];
for i=1:size(connectivities, 1)
    connected = find(connectivities(i, :)~=0);
    for j=1:length(connected)
        if ~isempty(strfind(atom_names{i}, 'H')) || ~isempty(strfind(atom_names{connected(j)}, 'H'))
            index = length(edges)+1;
            edges(index).from.atom_index = i;
            edges(index).from.atom = atom_names{i};
            edges(index).from.coord = positions(i).coord;
            edges(index).to.coord = positions(connected(j)).coord;
            edges(index).to.atom = atom_names{connected(j)};
            edges(index).to.atom_index = connected(j);
        end
    end
end



