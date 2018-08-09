function out = mol_reached_a_stop_points(tline)
out = false;
if (length(tline) >= 3 && strcmp(tline(1:3), 'M  ')) || (length(tline) >= 6 && strcmp(tline(4:6), 'END')) 
    out = true;
end

