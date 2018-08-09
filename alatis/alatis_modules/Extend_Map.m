% adding protons to the map
function New_Map = Extend_Map(Map, protons_bonds)
New_Map = Map;
for i=1:length(Map)
    indices = find(protons_bonds(:, 1) == Map(i));
    for j = 1:length(indices)
        New_Map = [New_Map, protons_bonds(indices(j), 2)];
    end
end

