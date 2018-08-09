function [updated_prev_Map, new_map] = Update_prev_map_basedon_salts(SALTS, updated_prev_Map)
new_map = 1:length(updated_prev_Map);
modify = [];
for i=1:length(SALTS)
    for j=1:length(SALTS(i).heavy_atom_indices)
        modify = [modify; [SALTS(i).heavy_atom_indices(j), updated_prev_Map(SALTS(i).heavy_atom_indices(j))]];
    end
    for j=1:length(SALTS(i).protons)
        modify = [modify; [SALTS(i).protons(j), updated_prev_Map(SALTS(i).protons(j))]];
    end
end
% for i=1:size(modify, 1)
%     for j=modify(i)+1:length(updated_prev_Map)
%         updated_prev_Map(j) = updated_prev_Map(j)-1;
%     end
% end
remove_array = sort(modify(:, 1));

for i=length(remove_array):-1:1
    updated_prev_Map(remove_array(i)) = [];
    new_map(remove_array(i)) = [];
end
new_map = [new_map, (modify(:, 1))'];
updated_prev_Map = [updated_prev_Map, (modify(:, 2))'];
