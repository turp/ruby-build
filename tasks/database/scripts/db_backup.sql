BACKUP DATABASE [<%= db.name %>] 
TO  DISK = '<%= windowfy(path) %>' 
WITH FORMAT, INIT,  NAME = N'<%= db.name %> Full Backup', SKIP, REWIND, NOUNLOAD <%= ", COMPRESSION" if compress %>,  STATS = 10
GO
