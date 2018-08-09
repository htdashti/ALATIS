function modified_stero = update_stero_acc_orig_stero(orig_stero, modified_stero)
if isempty(orig_stero)
    return
end
for i=1:size(orig_stero, 1)
    index = find(orig_stero(i, 1) == modified_stero(:, 1));
    if orig_stero(i, 2) == modified_stero(max(index), 2)
        return
    else
        modified_stero = [modified_stero(:, 1), -1.*modified_stero(:, 2)];
    end
end
