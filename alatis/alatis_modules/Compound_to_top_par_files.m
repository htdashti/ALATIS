function Compound_to_top_par_files(top_fpath, par_fpath, data, Compound)
write_top(top_fpath, data, Compound)
write_par(par_fpath, data, Compound)




function write_par(par_fpath, data, Compound)
fout = fopen(par_fpath, 'w');
fprintf(fout, 'Remarks Generated by RUNER@NMRFAM\n');
fprintf(fout, 'Remarks %s\n\n', datestr(datetime));

% writing angles
Angles = Compound.Angles;
seen = false(length(Angles), 1);
Counter = 0;
for i=1:length(Angles)
    if ~seen(i)
        Counter = Counter+1;
        line = get_line_comments(Compound, 'par', 'Angles', Counter);
        write_par_angles(fout, Angles(i), line);
%         if ~isempty(line)
%             fprintf(fout, 'angle %5s %5s %5s %8.1f %8.2f ! %s\n', Angles(i).Atom1.type, Angles(i).Atom2.type, Angles(i).Atom3.type, str2double(Angles(i).kt), str2double(Angles(i).t0), line);
%         else
%             fprintf(fout, 'angle %5s %5s %5s %8.1f %8.2f\n', Angles(i).Atom1.type, Angles(i).Atom2.type, Angles(i).Atom3.type, str2double(Angles(i).kt), str2double(Angles(i).t0));
%         end
        for j=i+1:length(Angles)
            if ~seen(j)
                if (strcmpi(Angles(i).Atom1.type, Angles(j).Atom1.type) && ... % comparing a-b-c with a-b-c
                    strcmpi(Angles(i).Atom2.type, Angles(j).Atom2.type) && ...
                    strcmpi(Angles(i).Atom3.type, Angles(j).Atom3.type) ) || ...
                    (strcmpi(Angles(i).Atom1.type, Angles(j).Atom3.type) && ... % comparing a-b-c with c-b-a
                    strcmpi(Angles(i).Atom2.type, Angles(j).Atom2.type) && ...
                    strcmpi(Angles(i).Atom3.type, Angles(j).Atom1.type) )
                seen(j) = true;
                end
            end
        end
    end
end
fprintf(fout, '\n\n');

% writing bonds
Bonds = Compound.Bonds;
seen = false(length(Bonds), 1);
Counter = 0;
for i=1:length(Bonds)
    if ~seen(i)
        Counter = Counter+1;
        line = get_line_comments(Compound, 'par', 'Bonds', Counter);
        write_par_bond(fout, Bonds(i), line);
%         if ~isempty(line)
%             fprintf(fout, 'bond %5s %5s %8.1f %8.4f ! %s\n', Bonds(i).Atom1.type, Bonds(i).Atom2.type, (Bonds(i).kb), (Bonds(i).r0), line);
%         else
%             fprintf(fout, 'bond %5s %5s %8.1f %8.4f\n', Bonds(i).Atom1.type, Bonds(i).Atom2.type, (Bonds(i).kb), (Bonds(i).r0));
%         end
        for j=i+1:length(Bonds)
            if ~seen(j)
                if (strcmpi(Bonds(i).Atom1.type, Bonds(j).Atom1.type) && ... % checking for a-b for a-b
                    strcmpi(Bonds(i).Atom2.type, Bonds(j).Atom2.type)) || ...
                    (strcmpi(Bonds(i).Atom1.type, Bonds(j).Atom2.type) && ... % checking for b-a for a-b
                    strcmpi(Bonds(i).Atom2.type, Bonds(j).Atom1.type))
                seen(j) = true;
                end
            end
        end
    end
end
fprintf(fout, '\n\n');

% cleaning data
impropers = {};
remove = false(size(data, 1), 1);
for i=1:size(data, 1)
    if data{i, 1} == 0
        if ~strcmp(data{i, 2}, 'Dihedral')
            impropers{end+1} = data(i, :);
            remove(i) = true;
        end
    else
        remove(i) = true;
    end
end
data(remove, :) = []; % dihedrals are stored in data
% writing dihedral
remove = false(size(data, 1), 1);
for i=1:size(data, 1)
    i_atoms = data{i, 12};
    if ~remove(i)
        for j=i+1:size(data, 1)
            j_atoms= data{j, 12};
            if strcmpi(i_atoms{1}.type, j_atoms{1}.type) && ...
                    strcmpi(i_atoms{2}.type, j_atoms{2}.type) && ...
                    strcmpi(i_atoms{3}.type, j_atoms{3}.type) && ...
                    strcmpi(i_atoms{4}.type, j_atoms{4}.type)
                table = data{j, 11};
                for k=1:size(table, 1)
                    in_table = 0;
                    for l=1:size(data{i, 11}, 1)
                        if nnz(table(k, :) == data{i, 11}(l, :)) == 3
                            in_table = 1;
                            break
                        end
                    end
                    if in_table ==  0
                        data{i, 11} = [data{i, 11};table(k, :)];
                    end
                end
                remove(j) = true;
            end
        end
    end
end
data(remove, :) = [];
for i=1:size(data, 1)
    i_atoms = data{i, 12};
    if size(data{i, 11}, 1) > 1
        if ~isempty(data{i, 14})
            fprintf(fout, 'dihedral %5s %5s %5s %5s  mult %1i %7.3f %4i %8.2f ! %s\n', i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, size(data{i, 11}, 1), data{i, 11}(1, 1), data{i, 11}(1, 2), data{i, 11}(1, 3), data{i, 14});
        else
            fprintf(fout, 'dihedral %5s %5s %5s %5s  mult %1i %7.3f %4i %8.2f\n', i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, size(data{i, 11}, 1), data{i, 11}(1, 1), data{i, 11}(1, 2), data{i, 11}(1, 3));
        end
        for j=2:size(data{i, 11}, 1)
                fprintf(fout, '%s %7.3f %4i %8.2f\n', sprintf('%40s', ''), data{i, 11}(j, 1), data{i, 11}(j, 2), data{i, 11}(j, 3));
        end
    else
        if ~isempty(data{i, 11}) % no table
            if ~isempty(data{i, 14})
                fprintf(fout, 'dihedral %5s %5s %5s %5s %15.3f %4i %8.2f ! %s\n', i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, data{i, 11}(1, 1), data{i, 11}(1, 2), data{i, 11}(1, 3), data{i, 14});
            else
                fprintf(fout, 'dihedral %5s %5s %5s %5s %15.3f %4i %8.2f\n', i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, data{i, 11}(1, 1), data{i, 11}(1, 2), data{i, 11}(1, 3));
            end
        end
    end
end
fprintf(fout, '\n\n');

% writing improper
seen = false(length(impropers), 1);
for i=1:length(impropers)
    if ~seen(i)
        i_atoms = impropers{i}{12};
        if ~isempty(impropers{i}{11})
            if ~isempty(impropers{i}{14})
                fprintf(fout, 'improper %5s %5s %5s %5s %13.1f %4i %8.2f ! %s \n',i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, impropers{i}{11}(1, 1), impropers{i}{11}(1, 2), impropers{i}{11}(1, 3), impropers{i}{14});
            else
                fprintf(fout, 'improper %5s %5s %5s %5s %13.1f %4i %8.2f \n',i_atoms{1}.type, i_atoms{2}.type, i_atoms{3}.type, i_atoms{4}.type, impropers{i}{11}(1, 1), impropers{i}{11}(1, 2), impropers{i}{11}(1, 3));
            end
            for j=i+1:length(impropers)
                if ~seen(j)
                    j_atoms = impropers{j}{12};
                    if strcmpi(i_atoms{1}.type, j_atoms{1}.type) && ... 
                            strcmpi(i_atoms{2}.type, j_atoms{2}.type) && ...
                            strcmpi(i_atoms{3}.type, j_atoms{3}.type) && ...
                            strcmpi(i_atoms{4}.type, j_atoms{4}.type)
                        seen(j) = true;
                    end
                end
            end
        end
    end
end
fprintf(fout, '\n\n');
% writing non_bond
Nonb = Compound.Nonb;
seen = false(length(Nonb), 1);
% Counter = 0;
for i=1:length(Nonb)
    if ~seen(i)
        if Nonb(i).active
            fprintf(fout, 'nonb %5s %11.6f %11.6f %11.6f %11.6f\n', Nonb(i).atom, Nonb(i).val1, Nonb(i).val2, Nonb(i).val3, Nonb(i).val4);
            for j=i+1:length(Nonb)
                if ~seen(j)
                    if strcmp(Nonb(i).atom, Nonb(j).atom)
                        seen(j) = true;
                    end
                end
            end
        end
    end
end
fprintf(fout, '\n\n');

% writing Nbfix
Nbfix = Compound.Nbfix;
seen = false(length(Nbfix), 1);
for i=1:length(Nbfix)
    if ~seen(i) && Nbfix(i).active
        fprintf(fout, 'nbfix %5s %5s %16.8e %16.8e %16.8e %16.8e\n', Nbfix(i).atom1,Nbfix(i).atom2, Nbfix(i).val1, Nbfix(i).val2, Nbfix(i).val3, Nbfix(i).val4);
    end
end

fprintf(fout, '\n\n');
fclose(fout);

function write_par_bond(fout, bond, line)
if isfield(bond, 'kb') || isfield(bond, 'r0')
    fprintf(fout, 'bond %5s %5s ', bond.Atom1.type, bond.Atom2.type);
    if isfield(bond, 'kb')
        fprintf(fout, '%8.1f', (bond.kb));
    end
    if isfield(bond, 'r0')
        fprintf(fout, '%8.4f', (bond.r0));
    end
    if ~isempty(line)
        fprintf(fout, ' ! %s', line);
    end
    fprintf(fout, '\n');
end

function write_par_angles(fout, angle, line)
if isfield(angle, 'kt') || isfield(angle, 't0')
    fprintf(fout, 'angle %5s %5s %5s ', angle.Atom1.type, angle.Atom2.type, angle.Atom3.type);
    if isfield(angle, 'kt')
        fprintf(fout, '%8.1f ', str2double(angle.kt));
    end
    if isfield(angle, 't0')
        fprintf(fout, '%8.2f ', str2double(angle.t0));
    end
    if ~isempty(line)
        fprintf(fout, ' ! %s', line);
    end
    fprintf(fout, '\n');
end

function write_top(top_fpath, data, Compound)
fout = fopen(top_fpath, 'w');
% write remarks
fprintf(fout, 'Remarks ALATIS-XPLOR GUI-Topology file\n');
fprintf(fout, 'Remarks %s\n\n', datestr(datetime));
fprintf(fout, 'Remarks input files comments and remarks:\n');
for i=1:length(Compound.Comments.top)
    fprintf(fout, 'REMARKS\t%s\n', Compound.Comments.top{i});
end
fprintf(fout, 'Remarks end of input files comments and remarks\n');
% % set params
% try
%     if ~isempty(Compound.Set_params.top)
%         fprintf(fout, 'set ');
%         for i=1:length(Compound.Set_params.top)
%             fprintf(fout, '%s=%s ', Compound.Set_params.top(i).term, Compound.Set_params.top(i).value);
%         end
%         fprintf(fout, 'end\n\n');
%     end
% end
% set Autogenerate_params
% try
%     if ~isempty(Compound.Autogenerate_params.top)
%         fprintf(fout, 'autogenerate ');
%         for i=1:length(Compound.Autogenerate_params.top)
%             fprintf(fout, '%s=%s ', Compound.Autogenerate_params.top(i).term, Compound.Autogenerate_params.top(i).value);
%         end
%         fprintf(fout, 'end\n\n');
%     end
% end
% writing mass
Atoms = Compound.Atoms;
seen = false(length(Atoms), 1);
Counter = 0;
for i=1:length(Atoms)
    if ~seen(i)
        Counter = Counter+1;
        line = get_line_comments(Compound, 'top', 'mass', Counter);
        if ~isempty(line)
            fprintf(fout, 'mass %-5s %8.3f ! %s\n', Atoms(i).type, str2double(Atoms(i).mass), line);
        else
            fprintf(fout, 'mass %-5s %8.3f\n', Atoms(i).type, str2double(Atoms(i).mass));
        end
        for j=i+1:length(Atoms)
            if strcmpi(Atoms(i).type, Atoms(j).type) && strcmpi(Atoms(i).mass, Atoms(j).mass)
                seen(j) =true;
            end
        end
    end
end
fprintf(fout, '\n\n');
% writing residue
if ~isempty(Compound.residue_name)
    fprintf(fout, 'residue %s \n\n', Compound.residue_name);
end
%fprintf(fout, 'group\n\n');

% writing atoms:
for i=1:length(Atoms)
    Atoms(i).index = i;
end
seen = false(length(Atoms), 1);
for i=1:length(Atoms)
    if ~seen(i)
        fprintf(fout, '\ngroup\n');
        line = get_line_comments(Compound, 'top', 'Atoms', Atoms(i).index);
        write_top_atom(fout, Atoms(i), line)
        for j=i+1:length(Atoms)
            if strcmp(Atoms(i).group_id, Atoms(j).group_id)
                seen(j) = true;
                line = get_line_comments(Compound, 'top', 'Atoms', Atoms(j).index);
                write_top_atom(fout, Atoms(j), line);
            end
        end
    end
end
fprintf(fout, '\n\n');
% writing angles
Angles = Compound.Angles;
angle_indices = 1:length(Angles);
remove = false(length(Angles), 1);
for i=1:length(Angles)
    if ~remove(i)
        for j=i+1:length(Angles)
            if ~remove(j) && ...
                    strcmp(Angles(i).Atom1.name, Angles(j).Atom3.name) && ... % c-b-a
                    strcmp(Angles(i).Atom2.name, Angles(j).Atom2.name) && ...
                    strcmp(Angles(i).Atom3.name, Angles(j).Atom1.name) || ...
                    strcmp(Angles(i).Atom1.name, Angles(j).Atom1.name) && ... % a-b-c
                    strcmp(Angles(i).Atom2.name, Angles(j).Atom2.name) && ...
                    strcmp(Angles(i).Atom3.name, Angles(j).Atom3.name)
                remove(j) = true;
            end
        end
    end
end
Angles(remove) = [];
angle_indices(remove) = [];
for i=1:length(Angles)
    line = get_line_comments(Compound, 'top', 'Angles', angle_indices(i));
    if ~isempty(line)
        fprintf(fout, '\tangle %-4s %-4s %-4s ! %s\n', Angles(i).Atom1.name, Angles(i).Atom2.name, Angles(i).Atom3.name, line);
    else
        fprintf(fout, '\tangle %-4s %-4s %-4s\n', Angles(i).Atom1.name, Angles(i).Atom2.name, Angles(i).Atom3.name);
    end
end
fprintf(fout, '\n\n');
% writing bonds
Bonds = Compound.Bonds;
for i=1:length(Bonds)
    line = get_line_comments(Compound, 'top', 'Bonds', i);
    if ~isempty(line)
        fprintf(fout, '\tbond %-5s %-5s ! %s\n', Bonds(i).Atom1.name, Bonds(i).Atom2.name, line);
    else
        fprintf(fout, '\tbond %-5s %-5s\n', Bonds(i).Atom1.name, Bonds(i).Atom2.name);
    end
end
fprintf(fout, '\n\n');
% writing dihedrals
for i=1:size(data, 1)
    if data{i, 1} == 0 && strcmpi(data{i, 2}, 'Dihedral')
        if isempty(data{i, 13})
            fprintf(fout, '\tdihedral %-5s %-5s %-5s %-5s\n', data{i, 3}, data{i, 4}, data{i, 5}, data{i, 6});
        else
            fprintf(fout, '\tdihedral %-5s %-5s %-5s %-5s ! %s\n', data{i, 3}, data{i, 4}, data{i, 5}, data{i, 6}, data{i, 13});
        end
    end
end
fprintf(fout, '\n\n');
% writing impropers
for i=1:size(data, 1)
    if data{i, 1} == 0 && strcmpi(data{i, 2}, 'improper')
        if isempty(data{i, 13})
            fprintf(fout, '\timproper %-5s %-5s %-5s %-5s\n', data{i, 3}, data{i, 4}, data{i, 5}, data{i, 6});
        else
            fprintf(fout, '\timproper %-5s %-5s %-5s %-5s ! %s\n', data{i, 3}, data{i, 4}, data{i, 5}, data{i, 6}, data{i, 13});
        end
    end
end
fprintf(fout, '\n\n');
fprintf(fout, 'end\n');
fclose(fout);

function write_top_atom(fout, atom, line)
fprintf(fout, '\tatom %-5s ', atom.name);
if isfield(atom, 'type')
    fprintf(fout, 'type= %-5s ', atom.type);
end
if isfield(atom, 'charge')
    fprintf(fout, 'charge= %8.4f ', atom.charge);
end
fprintf(fout, ' end ');
if ~isempty(line)
    fprintf(fout, ' ! %s ', line);
end
fprintf(fout, '\n');
%            fprintf(fout, '\tatom %-5s type= %-5s charge= %8.4f end ! %s\n', atom(i).name, atom(i).type, atom(i).charge, line);


function out = get_line_comments(Compound, ftype, category, Counter)
out = '';
try
    if isfield(Compound, 'Line_comments') && isfield(Compound.Line_comments, ftype) && isfield(Compound.Line_comments.(ftype), category)
        out = Compound.Line_comments.(ftype).(category)(Counter).note;
    end
catch
    out = '';
end






