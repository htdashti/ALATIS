function matrix = make_symmetric(matrix)

for i=1:size(matrix, 1)
    for j=1:size(matrix, 2)
        if matrix(i, j) == 1
            matrix(j, i) = 1;
        end
        if matrix(j, i) == 1
            matrix(i, j) = 1;
        end
    end
end
