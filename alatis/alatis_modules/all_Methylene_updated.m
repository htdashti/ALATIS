function check = all_Methylene_updated(new_stero, Methylene)
check = true;
for i=1:length(Methylene)
    if min(abs(Methylene(i).index-new_stero(:, 1))) ~= 0
        check = false;
        return
    end
end
