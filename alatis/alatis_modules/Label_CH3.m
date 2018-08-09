function Map = Label_CH3(CH3, atom_names, positions)

C_main_pos = positions(CH3.index).coord;
other_heavy_pos = positions(CH3.other_heavy).coord;
proton_1_pos = positions(CH3.proton_indices(1)).coord;
proton_2_pos = positions(CH3.proton_indices(2)).coord;
proton_3_pos = positions(CH3.proton_indices(3)).coord;
Map = [CH3.proton_indices(1); CH3.proton_indices(2); CH3.proton_indices(3)];

% center_zero
C_main_pos = C_main_pos - C_main_pos;
other_heavy_pos = other_heavy_pos- C_main_pos;
proton_1_pos = proton_1_pos - C_main_pos;
proton_2_pos = proton_2_pos - C_main_pos;
proton_3_pos = proton_3_pos - C_main_pos;

% move to z-axis
proton_1_pos = [proton_1_pos(1)/other_heavy_pos(1), proton_1_pos(2)-other_heavy_pos(2), proton_1_pos(3)-other_heavy_pos(3)];
proton_2_pos = [proton_2_pos(1)/other_heavy_pos(1), proton_2_pos(2)-other_heavy_pos(2), proton_2_pos(3)-other_heavy_pos(3)];
proton_3_pos = [proton_3_pos(1)/other_heavy_pos(1), proton_3_pos(2)-other_heavy_pos(2), proton_3_pos(3)-other_heavy_pos(3)];
%other_heavy_pos = [other_heavy_pos(1)/other_heavy_pos(1), other_heavy_pos(2)-other_heavy_pos(2), other_heavy_pos(3)-other_heavy_pos(3)];
angle = zeros(3, 1);
angle(1) = (180/pi)*mod(atan2(proton_1_pos(2),proton_1_pos(1)-1),2*pi);
angle(2) = (180/pi)*mod(atan2(proton_2_pos(2),proton_2_pos(1)-1),2*pi);
angle(3) = (180/pi)*mod(atan2(proton_3_pos(2),proton_3_pos(1)-1),2*pi);

[~, indices] = sort(angle);
Map(:, 2) = Map(indices, 1);
