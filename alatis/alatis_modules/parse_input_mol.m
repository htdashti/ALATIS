% outputs:
% Begin: the first line of a structure, containing #atoms and #bonds
% End: what comes after the edge definitions
% atoms: line containing atom definitions (including coordinates and flags)
% edges: a structure with from, to, and its corresponding flags

function [Begin, End, atoms, edges] = parse_input_mol(mol_path)
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
loop_starts = 0;
edge_counter = 0;
atom_counter = 0;
End = {};
while ischar(tline)
    if loop_starts == 1
        for iter=1:num_atoms
            atom_counter = atom_counter +1;
            atoms{atom_counter} = tline;
            if iter ~= num_atoms
                tline = fgetl(fin);
            end
        end
        for iter=1:num_edges
            tline = fgetl(fin);
            content = strsplit(tline);
            if (length(tline) > 3 && isnan(str2double(tline(1:3))))
                loop_starts = 2;
                continue
            end
            edge_counter = edge_counter+1;
            From = str2double(tline(1:3));
            To = str2double(tline(4:6));
            i = 7;
            content = {};
            local_counter = 3;
            while i+2 <= length(tline)
                content{local_counter} = tline(i:i+2);
                i = i+3;
                local_counter = local_counter+1;
            end
            edges(edge_counter).from = From; 
            edges(edge_counter).to = To; 
            content = zero_fill_content(content, 7);
            edges(edge_counter).rest = [str2double(content{3}), str2double(content{4}),str2double(content{5}),str2double(content{6}),str2double(content{7})];
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        Begin = tline;
        content = strsplit(tline);
        num_atoms = str2double(tline(1:3));
        num_edges = str2double(tline(4:6));
        atoms = cell(num_atoms, 1);
        if num_edges ~= 0
            edges(num_edges).from = 0;
        else
            edges = [];
        end
        loop_starts = 1;
    end
    tline = fgetl(fin);
    % populating End as soon as it sees a 'M ' after the edge definitions
    if mol_reached_a_stop_points(tline)
        End{end+1} = tline;
        loop_starts = 0 ;
    end
end
fclose(fin);

