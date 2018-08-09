function out = get_stero(inchi)

out = [];
[splited_inchis, mirrors] = split_inchi(inchi);
if length(splited_inchis) > 1
    Len = 0;
    for i=1:length(splited_inchis)
        temp = run_get_stero(splited_inchis{i});
        if ~isempty(temp)
            temp(:, 2) = mirrors(i).*temp(:, 2);
        end
        if ~isempty(temp)
            temp(:, 1) = Len+temp(:, 1);
            out = [out;temp];
        end
        Len = Len+num_heavy_atoms(splited_inchis{i});
    end
else
    out = run_get_stero(splited_inchis{1});
    if ~isempty(out)
        out(:, 2) = mirrors(1).*out(:, 2);
    end
end
