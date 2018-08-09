function write_acsubmit_php(atom_names, pdb_output_name, usremail, netcharge, rdc_file, noe_file, dres_fname)
global updated_mol_name Split_mol_names

% fout_msg = fopen('message_to_me', 'a');
% fprintf(fout_msg, 'in write ac_submit\n');
% fclose(fout_msg);


fout = fopen('upload.php', 'w');
fprintf(fout, '<html>\n');
fprintf(fout, '<body>\n');
fprintf(fout, '<?php\n');
fprintf(fout, '$Home_Add = ''http://runer.nmrfam.wisc.edu/'';\n');
fprintf(fout, '$myfile = fopen(''atom_labels'', "w");\n');
for i=1:length(atom_names)
    fprintf(fout, '$txt = "%d\t".$_POST["atomlabel%d"]."\\n";fwrite($myfile, $txt);\n', i,i);
end
fprintf(fout, 'fclose($myfile);\n');
fprintf(fout, 'chmod(''atom_labels'', 0777);\n');
fprintf(fout, '$cdir = getcwd();\n');

fprintf(fout, '$myfile = fopen(''alatis_ac.sub'', "w");\n');
fprintf(fout, '$txt = ''universe = vanilla''."\\n"; fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''executable = /websites/runer/distrib/main_ac''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''arguments = %s %s atom_labels %s %d %s %s %s map.txt ''.$cdir."\\n";fwrite($myfile, $txt);\n', pdb_output_name, updated_mol_name, usremail, netcharge, rdc_file, noe_file, dres_fname);
fprintf(fout, '$txt = ''environment = "LD_LIBRARY_PATH=""${LD_LIBRARY_PATH}:/raid/mcr/v901/runtime/glnxa64:/raid/mcr/v901/bin/glnxa64:/raid/mcr/v901/sys/os/glnxa64:/raid/mcr/v901/sys/opengl/lib/glnxa64"" "''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''error = temp_ac.err''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''output = temp_ac.out''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''log = temp_ac.log''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''should_transfer_files = yes''."\\n";fwrite($myfile, $txt);\n');
if ~isempty(Split_mol_names)
    fprintf(fout, '$txt = ''transfer_input_files = map.txt, /websites/runer/distrib/inchi-1, %s, %s, %s, %s, %s, atom_labels, inchi.inchi, %s''."\\n";fwrite($myfile, $txt);\n', dres_fname, rdc_file, noe_file, pdb_output_name, updated_mol_name, Split_mol_names{1});
else
    fprintf(fout, '$txt = ''transfer_input_files = map.txt, /websites/runer/distrib/inchi-1, %s, %s, %s, %s, %s, atom_labels, inchi.inchi''."\\n";fwrite($myfile, $txt);\n', dres_fname, rdc_file, noe_file, pdb_output_name, updated_mol_name);
end
fprintf(fout, '$txt = ''when_to_transfer_output = on_exit''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''transfer_output_files = alatis_ac.php, output.zip, antechamber_msg''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''periodic_remove = (time() - QDate) > 86400'' . "\\n"; fwrite($myfile, $txt);\n');
fprintf(fout, '$txt = ''queue''."\\n";fwrite($myfile, $txt);\n');
fprintf(fout, 'fclose($myfile);\n');

fprintf(fout, '$my_Command = ''condor_submit alatis_ac.sub'';\n');
fprintf(fout, 'system($my_Command);\n');
fprintf(fout, 'header("Location: wait.html");\n');
fprintf(fout, 'exit();\n');
fprintf(fout, '?>\n');
fprintf(fout, '</body>\n');
fprintf(fout, '</html>\n');
fclose(fout);

fout = fopen('wait.html', 'w');
Write_top_php(fout, 'Job submitted');
fprintf(fout, '<table border="1" width="100%%">\n');
fprintf(fout, '<tr><td width="15%%" align="center"><img src="http://runer.nmrfam.wisc.edu/html/logo1_nmrfam.png" alt="NMRFAM" style="width:50%%"></td><td align="center"><font size="6"><img src="http://runer.nmrfam.wisc.edu/html/logo_runer.png" alt="RUNER logo" style="width:50%%"><br><font size="4">Robust nomenclature and software for enhanced reproducibility in molecular modeling</font></font></td></tr>\n');
fprintf(fout, '<tr>\n');
fprintf(fout, '<td width="15%%" valign="top">\n');
fprintf(fout, '		<a class="active" href="http://runer.nmrfam.wisc.edu/">Home</a><br>\n');
%fprintf(fout, '		<a href="http://alatis.nmrfam.wisc.edu/examples.html">Processed databases</a><br>\n');
fprintf(fout, '		<a href="http://pine.nmrfam.wisc.edu/web_servers.html" target="_blank">NMRFAM Servers</a><br>\n');
fprintf(fout, '	</td>\n');
fprintf(fout, '	<td valign="top">\n');
fprintf(fout, '<font color="green">Your job has been submitted!</font><br>');
mins = ceil(2*exp(length(atom_names)*.02));
fprintf(fout, '<i>You will receive an email in approximately: %d minutes</i><br>', mins);
if mins > 1440
    fprintf(fout, '<font color="red"><i>Jobs will be stopped after 24hrs. If your job takes more than 24hrs, please contact us [dashti@wisc.edu]. </i></font><br>');
end
fprintf(fout, '<br>Thank you for using ALATIS<br>You will receive an email from us regarding the output files<br><br><br><br><br><br><br><br><br><br>\n');
fprintf(fout, '</td></tr>\n'); % this closes the output section
fprintf(fout, '\n');
fprintf(fout, '\n');
write_bottom(fout);
fclose(fout);
