function generate_python_script_for_mol3d_2d(atom_names)
fout = fopen('parse_svg.py', 'w');
C_list = find(strcmp(atom_names, 'C'));
H_list = find(strcmp(atom_names, 'H'));
O_list = find(strcmp(atom_names, 'O'));
N_list = find(strcmp(atom_names, 'N'));
Other_list = find(~strcmp(atom_names, 'N') & ~strcmp(atom_names, 'O') & ~strcmp(atom_names, 'C') & ~strcmp(atom_names, 'H'));

fprintf(fout, 'import xml.etree.ElementTree as ET\n');
write_a_def(fout,'is_oxygen', O_list)
write_a_def(fout,'is_nitrogen', N_list)
write_a_def(fout,'is_other', Other_list)
write_a_def(fout,'is_carbon', C_list)
write_a_def(fout,'is_hidrogen', H_list)

fprintf(fout, 'def other_names(name):\n');
fprintf(fout, '\tout=""\n');
for i=1:length(Other_list)
    fprintf(fout, '\tif name=="%d":\n', Other_list(i));
    fprintf(fout, '\t\tout = "%s"\n', atom_names{Other_list(i)});
end
fprintf(fout, '\treturn out\n');
fprintf(fout, 'tree = ET.parse(''mol.svg'')\n');
fprintf(fout, 'root = tree.getroot()\n');
fprintf(fout, 'graph = root.find(''{http://www.w3.org/2000/svg}g'')\n');
fprintf(fout, 'gs = graph.findall(''{http://www.w3.org/2000/svg}g'')\n');
fprintf(fout, 'for g in gs:\n');
fprintf(fout, '	txt = g.find(''{http://www.w3.org/2000/svg}text'')\n');
fprintf(fout, '	try:\n');
fprintf(fout, '		fsize_text = g.get(''font-size'')\n');
fprintf(fout, '		if fsize_text == None:\n');
fprintf(fout, '			fsize_text = ''18px''\n');
fprintf(fout, '	except:\n');
fprintf(fout, '		fsize_text = ''18px''\n');
fprintf(fout, '	if txt != None:\n');
fprintf(fout, '		input_text = txt.text\n');
fprintf(fout, '		if is_carbon(input_text):\n');
fprintf(fout, '			txt.set(''fill'', ''grey'')\n');
fprintf(fout, '		if is_hidrogen(input_text):\n');
fprintf(fout, '			txt.set(''fill'', ''black'')\n');
fprintf(fout, '		if is_oxygen(input_text):\n');
fprintf(fout, '			txt.text = ''O''+txt.text\n');
fprintf(fout, '			txt.set(''fill'', ''red'')\n');
fprintf(fout, '			txt.set(''font-size'', str(float(fsize_text.replace(''px'', ''''))/1.5)+''px'')\n');
fprintf(fout, '			g.set(''font-style'', "normal")\n');
fprintf(fout, '		if is_nitrogen(input_text):\n');
fprintf(fout, '			txt.text = ''N''+txt.text\n');
fprintf(fout, '			txt.set(''fill'', ''blue'')\n');
fprintf(fout, '			txt.set(''font-size'', str(float(fsize_text.replace(''px'', ''''))/1.5)+''px'')\n');
fprintf(fout, '			g.set(''font-style'', "normal")\n');
fprintf(fout, '		if is_other(input_text):\n');
fprintf(fout, '			txt.text = other_names(input_text)+txt.text\n');
fprintf(fout, '			txt.set(''fill'', ''green'')\n');
fprintf(fout, '			txt.set(''font-size'', str(float(fsize_text.replace(''px'', ''''))/1.5)+''px'')\n');
fprintf(fout, '			g.set(''font-style'', "normal")\n');
fprintf(fout, '\n');
fprintf(fout, 'tree.write(''temp.svg'')\n');

function write_a_def(fout, fname, list)
fprintf(fout, 'def %s(name):\n', fname);
if isempty(list)
    fprintf(fout, '	indices = []\n');
else
    fprintf(fout, '	indices = [');
    for i=1:length(list)
        if i ~= length(list)
            fprintf(fout, '''%d'',', list(i));
        else
            fprintf(fout, '''%d'']\n', list(i));
        end
    end
end
fprintf(fout, '	if name in indices:\n');
fprintf(fout, '		out = True\n');
fprintf(fout, '	else:\n');
fprintf(fout, '		out = False\n');
fprintf(fout, '	return out\n');