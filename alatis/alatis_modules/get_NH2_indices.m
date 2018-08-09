% this function does the substitution for amine centers with Ch2-SH and
% uniquely labels the amine protons
function out = get_NH2_indices(Amine, positions, updated_mol_path, updated_mol_temp_path, inchi_temp_path, folder_path)
global Warning_to_user
rng('shuffle');
out = [];
for iter=1:5000
    Add_Ch2_SH(Amine, positions, updated_mol_path, updated_mol_temp_path);
    [Ch2_SH_inchi, ~] = run_inchi(updated_mol_temp_path, inchi_temp_path);
    orig_stero = get_stero(Ch2_SH_inchi);
    [modified_inchi, modified_aux_info] = get_Ch2_SH_new_inchi(Amine, updated_mol_temp_path, inchi_temp_path, folder_path);
    modified_stero = get_stero(modified_inchi);
    if ~isempty(modified_stero)
        break
    end
end

modified_stero = update_stero_acc_orig_stero(orig_stero, modified_stero);
if isempty(modified_stero)
    fout = fopen('rand_NH2', 'a');
    fprintf(fout, '%s\n', folder_path);
    fclose(fout);
    Warning_to_user{end+1} = 'The InChI-1 program has generated the following warning. Check the structure file for possible problems:';
    Warning_to_user{end+1} = 'Processing NH2 reported a warning while using inchi-1 program! Aborting NH2 labeling.';
    return
end
N_layer_map = get_NLayer_map(modified_aux_info);
index = N_layer_map(:, 2) == Amine.index;
index = N_layer_map(index, 1);
index = modified_stero(:, 1) == index;
sign = modified_stero(index, 2);

if sign == -1
else
    if Amine.proton_indices(1) > Amine.proton_indices(2)
        out = [Amine.proton_indices(2);Amine.proton_indices(1)];
    end
end
