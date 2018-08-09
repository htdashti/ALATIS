function [heavy_atom_list, connections_list, protons_list, stero_list, mirror_list] = get_inchi_components(inchi)
content = strsplit(inchi, '/');
heavy_atoms = content{2};
heavy_atom_list = {};
heavy_content = strsplit(heavy_atoms, '.');
for i=1:length(heavy_content)
    current_block = heavy_content{i};
    if ~isnan(str2double(current_block(1)))
        j = 1;
        while ~isnan(str2double(current_block(j)))
            j=j+1;
        end
        num_str = current_block(1:j-1);
        if strcmp(current_block(j), '*')
            current_block = current_block(j+1:end);
        else
            current_block = current_block(j:end);
        end
        for j=1:str2double(num_str)
            heavy_atom_list{end+1} = current_block;
        end
    else
        heavy_atom_list{end+1} = current_block;
    end
end
if length(content) < 3
    connections_list = cell(length(heavy_atom_list), 1);
    protons_list= cell(length(heavy_atom_list), 1);
    stero_list = cell(length(heavy_atom_list), 1);
    return
end

connections_list = cell(length(heavy_atom_list), 1);
for content_index = 3:length(content)
    connections = content{content_index};
    if strcmp(connections(1), 'c')
        connections = connections(2:end);
        splitted = strsplit(connections, ';', 'CollapseDelimiters', false);
        connections_list = {};
        for i=1:length(splitted)
            if ~isempty(strfind(splitted{i}, '*'))
                split = strsplit(splitted{i}, '*', 'CollapseDelimiters', false);
                for j=1:str2double(split{1})
                    connections_list{end+1} = split{2};
                end
            else
                connections_list{end+1} = splitted{i};
            end
        end
        break
    end
end

protons_list= cell(length(heavy_atom_list), 1);
for content_index = 3:length(content)
    protons = content{content_index};
    if strcmp(protons(1), 'h')
        protons = protons(2:end);
        splitted = strsplit(protons, ';', 'CollapseDelimiters', false);
        protons_list = {};
        for i=1:length(splitted)
            current_block = splitted{i};
            if ~isempty(strfind(current_block, '*'))
                c_split = strsplit(current_block, '*');
                for j=1:str2double(c_split{1})
                    protons_list{end+1} = c_split{2};
                end
            else
                protons_list{end+1} = current_block;
            end
        end
        break;
    end
end

stero_list = cell(length(heavy_atom_list), 1);
for i=length(content):-1:1
    if strcmp(content{i}(1), 't')
        stero_list = {};
        stero = content{i};
        stero = stero(2:end);
        split = strsplit(stero, ';', 'CollapseDelimiters', false);
        for j=1:length(split)
            if ~isempty(strfind(split{j}, '*'))
                n_split = strsplit(split{j}, '*', 'CollapseDelimiters', false);
                for k=1:str2double(n_split{1})
                    stero_list{end+1} = n_split{2};
                end
            else
                stero_list{end+1} = split{j};
            end
        end
        break
    end
end


mirror_list = ones(length(heavy_atom_list), 1);
for i=length(content):-1:1
    if strcmp(content{i}(1), 'm')
        mirrors = content{i};
        mirrors = mirrors(2:end);
        split = strsplit(mirrors, '.', 'CollapseDelimiters', false);
        if length(split) == length(mirror_list)
            for j=1:length(split)
                if ~isempty(split{j}) % if empty or 0, multiply by 1, if is 1, multiply t by -1
                    if str2double(split{j}) == 1
                        mirror_list(j) = -1;
                    end
                end
            end
            break
        else
            counter = 0;
            for j=1:length(split)
                if ~isempty(split{j})
                    m_array = split{j};
                    for k=1:length(m_array)
                        if str2double(m_array(k)) == 0
                            counter = counter+1;
                        else
                            counter = counter+1;
                            mirror_list(counter) = -1;
                        end
                    end
                else
                    counter = counter+1;
                end
            end
        end
    end
end

