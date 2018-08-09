function out = is_salt(formula)
out = 1;
return
out = 0;
i = 0;
i=i+1; Salts{i} = 'Na';
i=i+1; Salts{i} = 'Cl';
i=i+1; Salts{i} = 'I';
i=i+1; Salts{i} = 'O4S';
for i=1:length(Salts)
    if ~isempty(strfind(formula, Salts{i}))
        out = 1;
        return
    end
end
