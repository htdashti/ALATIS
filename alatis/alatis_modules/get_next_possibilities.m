function array = get_next_possibilities(array)
for i=length(array):-1:1
    if array(i) == 1
        array(i) = 2;
        return
    else
        array(i) = 1;
    end
end
