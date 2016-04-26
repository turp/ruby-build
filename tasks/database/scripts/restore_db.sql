USE master

ALTER DATABASE <%= db.name %> SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE <%= db.name %>
FROM DISK = '<%= backup_file %>'
WITH <%= 
	s = ["NOUNLOAD, REPLACE, RECOVERY,STATS = 10"]
	s << logical_files.collect { |k, v| "MOVE '#{k}' TO '#{v}'"}
	s.join(", ") 
%>
