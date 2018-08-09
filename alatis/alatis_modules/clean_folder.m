% removing temporary and intermediate files.
function clean_folder(folder_path, fname)
system(sprintf('rm -f %s/temp.mol', folder_path));
system(sprintf('rm -f %s/prochiral_temp.mol', folder_path));
system(sprintf('rm -f %s/%s_temp_output.mol', folder_path, fname));
system(sprintf('rm -f %s/*.prb', folder_path));
system(sprintf('rm -f %s/*.log', folder_path));

system(sprintf('rm -f %s/alatis_output_%s.log', folder_path, fname));
system(sprintf('rm -f %s/prechecked_%s', folder_path, fname));
system(sprintf('rm -rf %s/results', folder_path));
system(sprintf('rm -rf %s/report.zip', folder_path));
