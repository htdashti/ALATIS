function steros = get_steros(Methylene, new_stero)
steros = zeros(length(Methylene), 1);
for i=1:length(Methylene)
    index = find(Methylene(i).index==new_stero(:, 1));
    steros(i) = new_stero(index, 2);
end


