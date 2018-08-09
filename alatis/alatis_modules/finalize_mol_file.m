% this is to process non-M tags, before M END
function finalize_mol_file(updated_mol_path, updated_prev_Map)
global PRE_M_block
if isempty(PRE_M_block)
    return
end
fin = fopen(updated_mol_path, 'r');
tline = fgetl(fin);
line_counter = 0;
while ischar(tline)
    if length(tline) >= 3 && strcmp(tline(1:3), 'M  ') && ~isempty(PRE_M_block)
        [Array, line_counter] = Process_property_PRE_M(Array, line_counter, updated_prev_Map);
        PRE_M_block = [];
    end
    line_counter = line_counter+1;
    Array{line_counter} = tline;
    tline = fgetl(fin);
end
fclose(fin);
fout = fopen(updated_mol_path, 'w');
for i=1:length(Array)
    fprintf(fout, '%s\n', Array{i});
end
fclose(fout);


function [Array, line_counter] = Process_property_PRE_M(Array, line_counter, updated_prev_Map)
global PRE_M_block
content = strsplit(PRE_M_block, '\n');
for i=1:length(content)
    line = content{i};
    if length(line) >= 3 && strcmp(line(1:3), 'A  ')
        con = strsplit(line);
        prev_index = str2double(con{2});
        index = find(prev_index == updated_prev_Map);
        line_counter = line_counter+1;
        Array{line_counter} = sprintf('A  %3d', index);
    else
        if length(line) >= 3 && strcmp(line(1:3), 'V  ')
            con = strsplit(line);
            prev_index = str2double(con{2});
            index = find(prev_index == updated_prev_Map);
            line_counter = line_counter+1;
            Array{line_counter} = sprintf('V  %3d %s', index, con{3});
        else
            if length(line) >= 3 && strcmp(line(1:3), 'G  ')
                prev_index1 = str2double(line(4:6));
                prev_index2 = str2double(line(7:9));
                index1 = find(prev_index1 == updated_prev_Map);
                index2 = find(prev_index2 == updated_prev_Map);
                line_counter = line_counter+1;
                Array{line_counter} = sprintf('G  %3d%3d', index1, index2);
            else
                line_counter = line_counter+1;
                Array{line_counter} = line;
            end
        end
        
    end
end          