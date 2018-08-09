function [out, coeff] = do_steros_match(new_stero, orig_stero)
out = false;
coeff = 1;
Sum = 0;
for i=1:size(orig_stero, 1)
    Sum = Sum+sum(new_stero(:, 1) == orig_stero(i, 1) & new_stero(:, 2) == orig_stero(i, 2));
end
if Sum == size(orig_stero, 1)
    out = true;
    return
end
coeff = -1;
orig_stero(:, 2) = coeff.*orig_stero(:, 2);
Sum = 0;
for i=1:size(orig_stero, 1)
    Sum = Sum+sum(new_stero(:, 1) == orig_stero(i, 1) & new_stero(:, 2) == orig_stero(i, 2));
end
if Sum == size(orig_stero, 1)
    out = true;
    return
end
