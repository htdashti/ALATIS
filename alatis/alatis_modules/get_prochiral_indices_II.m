% this is to generate uniq labels for protons at prochiral centers
function Map = get_prochiral_indices_II(Methylene, mol_temp_path, folder_path, inchi, inchi_temp_path)
global failed_methylene_check
Map = [];
orig_stero = get_stero(inchi);
array = ones(length(Methylene), 1);
check1 = false;
check2 = false;
check3 = false;
iter_counter = 0;
for i=1:2^length(Methylene)
    iter_counter = iter_counter+1;
    new_inchi = get_new_inchi(array, Methylene, mol_temp_path, folder_path, inchi_temp_path);
    new_stero = get_stero(new_inchi);
    if isempty(new_stero) % we didnt impose anything
        for out_i=1:length(Methylene)
            Map = [Map;[Methylene(out_i).proton_indices, Methylene(out_i).proton_indices]];
        end
        return
    end
    if ~isempty(orig_stero) && size(orig_stero, 1) == size(new_stero, 1) && sum(sort(new_stero(:, 1)) == sort(orig_stero(:, 1))) == size(orig_stero, 1)
        check3 = true;
    end
    if all_Methylene_updated(new_stero, Methylene)
        if isempty(orig_stero)
            check1 = true;
            check2 = true;
        else
            [flag, coeff] = do_steros_match(new_stero, orig_stero);
            if flag
                new_stero(:, 2) = coeff.*new_stero(:, 2);
                check1 = true;
                check2 = true;
            end
        end
    end
    if check1 && check2
        break
    end
    array = get_next_possibilities(array);
    if iter_counter > 1024
        break;
    end
end
if check1 && check2
    failed_methylene_check = 0;
    steros = get_steros(Methylene, new_stero);
    for i=1:length(Methylene)
        indices = Methylene(i).proton_indices;
        Max = max(indices);
        Min = min(indices);
        if steros(i) > 0
            if array(i) == 1
                new_indices(1, 1) = Min;
                new_indices(2, 1) = Max;
                
            else
                new_indices(1, 1) = Max;
                new_indices(2, 1) = Min;
            end
        else
            new_indices = indices;
        end
        Map = [Map; [indices, new_indices]];
    end
else
    if iter_counter > 1024
        failed_methylene_check = 1;
    else
        failed_methylene_check = 0;
    end
    if check3 == true % substituting D's does not change stero-chmistry
        for out_i=1:length(Methylene)
            Map = [Map;[Methylene(out_i).proton_indices, Methylene(out_i).proton_indices]];
        end
    else
        failed_methylene_check = 1;
    end
end
i = 0;

