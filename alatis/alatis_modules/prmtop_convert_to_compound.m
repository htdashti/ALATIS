function Compound = prmtop_convert_to_compound(prmtop_fname, mol_fname, inchi_fname)

use_chiral = true;
structure = get_structures(prmtop_fname);
Structure = get_Structure(structure, mol_fname, inchi_fname, use_chiral);

Compound.residue_name = Structure.Title;
Compound = fill_atoms(Compound, Structure);
Compound = fill_bonds(Compound, Structure);
Compound = fill_angles(Compound, Structure);
Compound = fill_dihedral(Compound, Structure);
Compound = fill_improper(Compound, Structure);
Compound.Comments.top = {};
Compound.Comments.par = {};
Compound.Set_params.top.term = 'echo';Compound.Set_params.top.value = 'true';
Compound.Set_params.par.term = 'echo';Compound.Set_params.par.value = 'true';
Compound.Autogenerate_params.top(1).term = 'angles';Compound.Autogenerate_params.top(1).value = 'True';
Compound.Autogenerate_params.top(2).term = 'dihedrals';Compound.Autogenerate_params.top(1).value = 'True';
Compound.Autogenerate_params.par = [];
Compound = fill_line_comments(Compound, Structure);


function Compound = fill_line_comments(Compound, Structure)
for i=1:length(Structure.Atoms)
    Compound.Line_comments.top.mass(i).note = '';
    Compound.Line_comments.top.Atoms(i).note = '';
    Compound.Line_comments.par.Nonbs(i).note = '';
end
for i=1:length(Structure.Bonds)
    Compound.Line_comments.top.bond(i).note = '';
    Compound.Line_comments.par.Bonds(i).note = '';
end
for i=1:length(Structure.Angles)
    Compound.Line_comments.top.Angles(i).note = '';
    Compound.Line_comments.par.Angles(i).note = '';
end
for i=1:length(Structure.dihedral.proper_array_indices)
    Compound.Line_comments.top.Dihedrals(i).note = '';
    Compound.Line_comments.par.Dihedrals(i).note = '';    
end
for i=1:size(Structure.dihedral.improper_indices, 1)+length(Structure.improper_chiral)
    Compound.Line_comments.top.Impropers(i).note = '';
    Compound.Line_comments.par.Impropers(i).note = '';    
end
for i=1:length(Structure.dihedral.proper_array_indices)
    Compound.Line_comments.top.Dihedrals(i).note = '';
    Compound.Line_comments.par.Dihedrals(i).note = '';    
end
function [phi, period, phase] = get_angle_prop(index, dfc, dperiod, dphase)

phi = dfc(index);
period = round(dperiod(index));
phase = 57.2958*dphase(index);
function Compound = fill_improper(Compound, Structure)
Compound.Impropers = [];
impropers = Structure.dihedral.improper_indices;
dfc = Structure.dihedral.dihedral_force_constant;
dperiod = Structure.dihedral.dihedral_periodicity;
dphase = Structure.dihedral.dihedral_phase;
for i=1:size(impropers, 1)
    array = impropers(i, :);
    Compound.Impropers(i).Atom1.name = Structure.Atoms(array(1)).atom_name; Compound.Impropers(i).Atom1.type = Structure.Atoms(array(1)).atom_type;
    Compound.Impropers(i).Atom2.name = Structure.Atoms(array(2)).atom_name; Compound.Impropers(i).Atom2.type = Structure.Atoms(array(2)).atom_type;
    Compound.Impropers(i).Atom3.name = Structure.Atoms(array(3)).atom_name; Compound.Impropers(i).Atom3.type = Structure.Atoms(array(3)).atom_type;
    Compound.Impropers(i).Atom4.name = Structure.Atoms(array(4)).atom_name; Compound.Impropers(i).Atom4.type = Structure.Atoms(array(4)).atom_type;
    [phi, period, phase] = get_angle_prop(array(5), dfc, dperiod, dphase);
    Compound.Impropers(i).Table = [phi, period, phase];
    Compound.Impropers(i).comments.top = '';
    Compound.Impropers(i).comments.par = '';
end
% chiral
if isfield(Compound, 'Impropers')
    Len = length(Compound.Impropers);
else
    Len = 0;
end
impro_chiral = Structure.improper_chiral;
for i=1:size(impro_chiral, 1)
    array = impro_chiral(i, :);
    Compound.Impropers(Len+i).Atom1.name = Structure.Atoms(array(1)).atom_name; Compound.Impropers(Len+i).Atom1.type = Structure.Atoms(array(1)).atom_type;
    Compound.Impropers(Len+i).Atom2.name = Structure.Atoms(array(2)).atom_name; Compound.Impropers(Len+i).Atom2.type = Structure.Atoms(array(2)).atom_type;
    Compound.Impropers(Len+i).Atom3.name = Structure.Atoms(array(3)).atom_name; Compound.Impropers(Len+i).Atom3.type = Structure.Atoms(array(3)).atom_type;
    Compound.Impropers(Len+i).Atom4.name = Structure.Atoms(array(4)).atom_name; Compound.Impropers(Len+i).Atom4.type = Structure.Atoms(array(4)).atom_type;
    %[~, ~, phase] = get_angle_prop(array(5), dfc, dperiod, dphase);
    Compound.Impropers(Len+i).Table = [20000, 0, 70];
    Compound.Impropers(Len+i).comments.top = '!chiral';
    Compound.Impropers(Len+i).comments.par = '!chiral';    
end
function Compound = fill_dihedral(Compound, Structure)
Compound.Dihedrals = [];
Dihedrals = Structure.dihedral.proper_array_indices;
dfc = Structure.dihedral.dihedral_force_constant;
dperiod = Structure.dihedral.dihedral_periodicity;
dphase = Structure.dihedral.dihedral_phase;

for i=1:length(Dihedrals)
    array = Dihedrals(i).array(1, :);
    Compound.Dihedrals(i).Atom1.name = Structure.Atoms(array(1)).atom_name; Compound.Dihedrals(i).Atom1.type = Structure.Atoms(array(1)).atom_type;
    Compound.Dihedrals(i).Atom2.name = Structure.Atoms(array(2)).atom_name; Compound.Dihedrals(i).Atom2.type = Structure.Atoms(array(2)).atom_type;
    Compound.Dihedrals(i).Atom3.name = Structure.Atoms(array(3)).atom_name; Compound.Dihedrals(i).Atom3.type = Structure.Atoms(array(3)).atom_type;
    Compound.Dihedrals(i).Atom4.name = Structure.Atoms(array(4)).atom_name; Compound.Dihedrals(i).Atom4.type = Structure.Atoms(array(4)).atom_type;
    Table = [];
    for j=1:size(Dihedrals(i).array, 1)
        [phi, period, phase] = get_angle_prop(Dihedrals(i).array(j, 5), dfc, dperiod, dphase);
        Table = [Table;[phi, period, phase]];
    end
    Compound.Dihedrals(i).Table = Table;
    Compound.Dihedrals(i).comments.top = '';
    Compound.Dihedrals(i).comments.par = '';
end
function Compound = fill_angles(Compound, Structure)
Compound.Angles = [];
Angles = Structure.Angles;
for i=1:length(Angles)
    Compound.Angles(i).Atom1.name = Structure.Atoms(Angles(i).indices(1)).atom_name;
    Compound.Angles(i).Atom1.type = Structure.Atoms(Angles(i).indices(1)).atom_type;
    Compound.Angles(i).Atom2.name = Structure.Atoms(Angles(i).indices(2)).atom_name;
    Compound.Angles(i).Atom2.type = Structure.Atoms(Angles(i).indices(2)).atom_type;
    Compound.Angles(i).Atom3.name = Structure.Atoms(Angles(i).indices(3)).atom_name;
    Compound.Angles(i).Atom3.type = Structure.Atoms(Angles(i).indices(3)).atom_type;
    Compound.Angles(i).kt = sprintf('%f', Angles(i).angle_force_constant);
    Compound.Angles(i).t0 = sprintf('%f', Angles(i).angle_equil_value);
end
function Compound = fill_bonds(Compound, Structure)
Compound.Bonds = [];
Bonds = Structure.Bonds;
for i=1:length(Bonds)
    Compound.Bonds(i).Atom1.name = Structure.Atoms(Bonds(i).array(1)).atom_name;
    Compound.Bonds(i).Atom1.type = Structure.Atoms(Bonds(i).array(1)).atom_type;
    Compound.Bonds(i).Atom2.name = Structure.Atoms(Bonds(i).array(2)).atom_name;
    Compound.Bonds(i).Atom2.type = Structure.Atoms(Bonds(i).array(2)).atom_type;
    Compound.Bonds(i).kb = Bonds(i).bond_force_constant;
    Compound.Bonds(i).r0 = Bonds(i).bond_equil_value;
end
function Compound = fill_atoms(Compound, Structure)
Compound.Atoms = [];
Compound.Nbfix = [];
Compound.Nonb = [];
Atoms = Structure.Atoms;
ACOEFs = Structure.Non_Bounded.ACOEFs;
BCOEFs = Structure.Non_Bounded.BCOEFs;

for i=1:length(Atoms)
    Compound.Atoms(i).name = Atoms(i).atom_name;
    Compound.Atoms(i).type = Atoms(i).atom_type;
    Compound.Atoms(i).group_id = 'Group_1';
    if BCOEFs(i) == 0
        sigma = 0;
        epAmber = 0;
        ep2 = 0;
        sig2 = 0;
    else
        epAmber = 0.25 * BCOEFs(i) * BCOEFs(i) / ACOEFs(i);
        ep2 = epAmber / 2.0;
        sigma = (ACOEFs(i) / BCOEFs(i))^(1/6);
        sig2 = sigma;
    end
    Compound.Nonb(i).active = true;
    Compound.Nonb(i).atom = Atoms(i).atom_type;
    Compound.Nonb(i).val1 = epAmber;
    Compound.Nonb(i).val2 = sigma;
    Compound.Nonb(i).val3 = ep2;
    Compound.Nonb(i).val4 = sig2;
    Compound.Atoms(i).mass = sprintf('%f', Atoms(i).mass);
    Compound.Atoms(i).charge = Atoms(i).charge;
end
remove = false(length(Compound.Nonb), 1);
for i=1:length(Compound.Nonb)
    if ~remove(i)
        for j=i+1:length(Compound.Nonb)
            if strcmpi(Compound.Nonb(i).atom, Compound.Nonb(j).atom)
                remove(j) = true;
            end
        end
    end
end
Compound.Nonb(remove) = [];

function out = get_a_block(structure, name)
out = '';
for i=1:length(structure)
    if strcmpi(structure(i).title, name)
        out = structure(i);
        break
    end
end
if isempty(out)
    out = 'NAN';
end

function structure = get_structures(fname)
fin = fopen(fname, 'r');
structure(1).Version_line = fgetl(fin);
tline = fgetl(fin);
content = {};
while ischar(tline)
    if isempty(tline)
        index = length(structure)+1;
        structure(index).title = Title;
        structure(index).format.num_col = Num_col;
        structure(index).format.entity_len = entity_len;
        structure(index).content = {};
        structure(index).Version_line = '';
    end
    if length(tline) >= 5 && strcmp(tline(1:5), '%FLAG')
        if ~isempty(content)
            index = length(structure)+1;
            structure(index).title = Title;
            structure(index).format.num_col = Num_col;
            structure(index).format.entity_len = entity_len;
            structure(index).content = content;
            structure(index).Version_line = '';
        end
        Title = strrep(tline, '%FLAG', '');
        Title = strrep(Title, ' ', '');
    else
        if length(tline) >= 7 && strcmp(tline(1:7), '%FORMAT')
            format = strrep(tline, '%FORMAT', '');
            format = strrep(format, ' ', '');
            format = strrep(format, '(', '');
            format = strrep(format, ')', '');
            Num_col_str = '';
            num_col_flag = 1;
            entity_len_flag = 0;
            for i=1:length(format)
                if entity_len_flag
                    entity_len_str = format(i:end);
                    break
                end
                if num_col_flag
                    if ~isnan(str2double(format(i)))
                        Num_col_str = sprintf('%s%s', Num_col_str, format(i));
                    else
                        Num_col = str2double(Num_col_str);
                        num_col_flag = 0;
                        entity_len_flag = 1;
                    end
                end
            end
            entity_len = floor(str2double(entity_len_str));
            content = {};
        else
            for i=1:entity_len:length(tline)
                content{end+1} = tline(i:i+entity_len-1);
            end
        end
    end
    tline = fgetl(fin);
end

fclose(fin);
function Structure = get_Structure(structure, mol_path, inchi_fname, use_chiral)
%% Title
out = get_a_block(structure, 'TITLE');
Structure.Title = out.content{1};
%% set atoms info
atom_names = get_a_block(structure, 'ATOM_NAME');
atom_names = atom_names.content;
at = get_a_block(structure, 'AMBER_ATOM_TYPE');
at = at.content;
mass = get_a_block(structure, 'MASS');
mass = str2double((mass.content'));
Charge = get_a_block(structure, 'CHARGE');
Charge = str2double((Charge.content)')/18.2223;

Atoms = [];
for i=1:length(at)
    Atoms(i).atom_name = strrep(atom_names{i}, ' ', '');
    Atoms(i).atom_type = sprintf('%s_', strrep(at{i}, ' ', ''));
    Atoms(i).mass = mass(i);
    Atoms(i).charge = Charge(i);
end

Structure.Atoms = Atoms;

%% set angles atom indices
atom_index_angles_in_h = get_a_block(structure, 'ANGLES_INC_HYDROGEN');
atom_index_angles_wo_h = get_a_block(structure, 'ANGLES_WITHOUT_HYDROGEN');

angle_atom_counter = 0;
angle_atom_index = [];

content = [atom_index_angles_in_h.content, atom_index_angles_wo_h.content];
for i=1:4:length(content)
    angle_atom_counter = angle_atom_counter+1;
    angle_atom_index(angle_atom_counter, 1) = floor(str2double(content{i})/3)+1;
    angle_atom_index(angle_atom_counter, 2) = floor(str2double(content{i+1})/3)+1;
    angle_atom_index(angle_atom_counter, 3) = floor(str2double(content{i+2})/3)+1;
    angle_atom_index(angle_atom_counter, 4) = str2double(content{i+3});
end
afc = get_a_block(structure, 'ANGLE_FORCE_CONSTANT');
afc = str2double((afc.content)');
aev = get_a_block(structure, 'ANGLE_EQUIL_VALUE');
aev = 57.2958*str2double((aev.content)');

%Structure.Angles.atom_index = angle_atom_index; % store force_constant and equil_value here| needs updates on Angles_atom_index to Angles.atom_index 
Structure.Angles = [];
for i=1:size(angle_atom_index, 1)
    Structure.Angles(i).indices = angle_atom_index(i, :);
    Structure.Angles(i).angle_force_constant = afc(angle_atom_index(i, 4));
    Structure.Angles(i).angle_equil_value    = aev(angle_atom_index(i, 4));
end

%% set bonds atom indices
bond_index_angles_in_h = get_a_block(structure, 'BONDS_INC_HYDROGEN');
bond_index_angles_wo_h = get_a_block(structure, 'BONDS_WITHOUT_HYDROGEN');

bfc = get_a_block(structure, 'BOND_FORCE_CONSTANT');
bfc = str2double((bfc.content)');
bev = get_a_block(structure, 'BOND_EQUIL_VALUE');
bev = str2double((bev.content)');

bond_atom_counter = 0;

content = [bond_index_angles_in_h.content, bond_index_angles_wo_h.content];
Structure.Bonds = [];
for i=1:3:length(content)
    bond_atom_counter = bond_atom_counter+1;
    index = str2double(content{i+2});
    Structure.Bonds(bond_atom_counter).array = [floor(str2double(content{i})/3)+1, floor(str2double(content{i+1})/3)+1, index];
    Structure.Bonds(bond_atom_counter).bond_force_constant = bfc(index);
    Structure.Bonds(bond_atom_counter).bond_equil_value = bev(index);
end

%% get dihedral angles
dia_index_angles_in_h = get_a_block(structure, 'DIHEDRALS_INC_HYDROGEN');
dia_index_angles_wo_h = get_a_block(structure, 'DIHEDRALS_WITHOUT_HYDROGEN');

dih_proper_counter = 0;
dih_improper_counter = 0;
dih_improper_index = [];
dih_proper_index = [];
content = [dia_index_angles_in_h.content, dia_index_angles_wo_h.content];
for i=1:5:length(content)
    index1 = floor(str2double(content{i})/3);
    index2 = floor(str2double(content{i+1})/3);
    index3 = floor((str2double(content{i+2}))/3);
    index4 = floor((str2double(content{i+3}))/3);
    index5 = str2double(content{i+4});
    array = [index1+1, index2+1, abs(index3)+1, abs(index4)+1, index5];
    %if strcmp(Atoms(array(1)).atom_type, 'n_') && strcmp(Atoms(array(2)).atom_type, 'o_')
    if str2double(content{i+3}) > 0 % proper
        if str2double(content{i+2}) > 0
            dih_proper_counter = dih_proper_counter+1;
            dih_proper_index(dih_proper_counter).array = array;
        else % muli
            if dih_proper_counter >= 1 && nnz(dih_proper_index(dih_proper_counter).array(1, 1:4) == [index1+1, index2+1, abs(index3)+1, abs(index4)+1]) == 4
                dih_proper_index(dih_proper_counter).array = [dih_proper_index(dih_proper_counter).array; array];
            else % first proper angle or doesnt match
                dih_proper_counter = dih_proper_counter+1;
                dih_proper_index(dih_proper_counter).array = array;
            end
        end
    else
        dih_improper_counter = dih_improper_counter+1;
        dih_improper_index(dih_improper_counter, 1) = index1+1;
        dih_improper_index(dih_improper_counter, 2) = index2+1;
        dih_improper_index(dih_improper_counter, 3) = abs(index3)+1;
        dih_improper_index(dih_improper_counter, 4) = abs(index4)+1;
        dih_improper_index(dih_improper_counter, 5) = index5;
    end
end
Structure.dihedral.improper_indices = dih_improper_index;
Structure.dihedral.proper_array_indices = dih_proper_index;

dfc = get_a_block(structure, 'DIHEDRAL_FORCE_CONSTANT');dfc = str2double((dfc.content)');
dperiod = get_a_block(structure, 'DIHEDRAL_PERIODICITY');dperiod = str2double((dperiod.content)');
dphase = get_a_block(structure, 'DIHEDRAL_PHASE');dphase = str2double((dphase.content)');

Structure.dihedral.dihedral_force_constant = dfc;
Structure.dihedral.dihedral_periodicity = dperiod;
Structure.dihedral.dihedral_phase = dphase; % will be *57.2958 in write par
%% get chiral impropers
if use_chiral
    improper_chiral = get_chiral_impropers(mol_path, inchi_fname);
    Structure.improper_chiral = improper_chiral;
else
    Structure.improper_chiral = [];
end
%% get lennard-Jones non-bounded
atype_index = get_a_block(structure, 'ATOM_TYPE_INDEX');
atype_index = str2double((atype_index.content)');

npi = get_a_block(structure, 'NONBONDED_PARM_INDEX');
npi = str2double((npi.content)');

LJ_acoef = get_a_block(structure, 'LENNARD_JONES_ACOEF');
LJ_acoef = str2double((LJ_acoef.content)');

LJ_bcoef = get_a_block(structure, 'LENNARD_JONES_BCOEF');
LJ_bcoef = str2double((LJ_bcoef.content)');

ntypes = max(atype_index);
ACOEFs = zeros(length(atype_index), 1);
BCOEFs = zeros(length(atype_index), 1);
for id=1:length(atype_index)
    atomTypeId = atype_index(id);
    index = ntypes * (atomTypeId - 1) + atomTypeId;
    nonBondId = npi(index);
    ACOEFs(id) = LJ_acoef(nonBondId);
    BCOEFs(id) = LJ_bcoef(nonBondId);
end
Structure.Non_Bounded.ACOEFs = ACOEFs;
Structure.Non_Bounded.BCOEFs = BCOEFs;
function improper_chiral = get_chiral_impropers(mol_path, inchi_fname)
improper_chiral = [];
[~, matrix, positions] = convert_mol_to_detailed_graph(mol_path);
matrix = make_symmetric(matrix);

fin = fopen(inchi_fname, 'r');
inchi = fgetl(fin);
fclose(fin);

content = strsplit(inchi, '/');
slash_t_layers = {};
for i=1:length(content)
    if strcmp(content{i}(1), 't')
        slash_t_layers{end+1} = strrep(content{i}, 't', '');
    end
end
if isempty(slash_t_layers)
    return
end
chiral_nodes = [];
for i=1:length(slash_t_layers)
    content = strsplit(slash_t_layers{i}, ',');
    for j=1:length(content)
        content{j} = strrep(content{j}, '+', '');
        content{j} = strrep(content{j}, '-', '');
        content{j} = strrep(content{j}, '?', '');
        chiral_nodes = [chiral_nodes; str2double(content{j})];
    end
end
chiral_nodes = unique(chiral_nodes);
for i=1:length(chiral_nodes)
    atom_index = chiral_nodes(i);
    ngb_nodes = find(matrix(atom_index, :));
    if length(ngb_nodes) == 4
        angle = imprDihAngle(positions(ngb_nodes(1)).coord, ...
                             positions(ngb_nodes(2)).coord, ...
                             positions(ngb_nodes(3)).coord, ...
                             positions(ngb_nodes(4)).coord);
        improper_chiral = [improper_chiral; [ngb_nodes, angle]];
    end
end
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
function [atom_names, matrix, positions] = convert_mol_to_detailed_graph(mol_path)
fin = fopen(mol_path, 'r');
tline = fgetl(fin);
loop_starts = 0;
while ischar(tline)
    if loop_starts == 1
        for iter = 1:num_atoms
            content = strsplit(tline);
            counter = counter+1;
            if isempty(content{1})
                atom_names{counter} = content{5}; %sprintf('%s%d', content{5}, counter);
                positions(counter).coord = [str2double(content{2}), str2double(content{3}), str2double(content{4})];
            else
                atom_names{counter} = content{4}; %sprintf('%s%d', content{4}, counter);
                positions(counter).coord = [str2double(content{1}), str2double(content{2}), str2double(content{3})];
            end
            if iter~= num_atoms
                tline= fgetl(fin);
            end
        end
        for iter =1:num_edges
            tline = fgetl(fin);
            from = str2double(tline(1:3));
            to = str2double(tline(4:6));
            matrix(from, to) = 1;
        end
    end
    if ~isempty(strfind(tline, 'V2000'))
        num_atoms = str2double(tline(1:3));
        num_edges = str2double(tline(4:6));
        matrix = zeros(num_atoms);
        atom_names = cell(num_atoms, 1);
        loop_starts = 1;
        counter = 0;
    end
    tline = fgetl(fin);
    if ~isempty(strfind(tline, 'M ')) ||(length(tline) >= 6 && strcmp(tline(4:6), 'END'))% ~isempty(strfind(tline, 'END'))
        break
    end
end
fclose(fin);
function angle = imprDihAngle(a, b, c, d)
ba = vec_sub(a, b);
bc = vec_sub(c, b);
cb = vec_sub(b, c);
cd = vec_sub(d, c);
n1 = crosproduct(ba, bc);
n2 = crosproduct(cb, cd);
angle = acos(sum(n1.*n2) / (vect_length(n1) * vect_length(n2))) * 180 / pi;
cp = crosproduct(n1, n2);
if (sum(cp.*bc) < 0)
    angle = -1 * angle;
end
function c=crosproduct(a, b)
    c = [a(2) * b(3) - a(3) * b(2), a(3) * b(1) - a(1) * b(3), a(1) * b(2) - a(2) * b(1)];
function out = vect_length(v)
    out = sqrt(sum(v.*v));
function out = vec_sub(aa, bb)
    out = aa-bb;

        
