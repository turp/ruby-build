USE MASTER
go
SET NOCOUNT ON

IF EXISTS (SELECT * FROM master.dbo.sysservers WHERE srvname = '<%= name %>')
BEGIN
	PRINT '<<< DROPPING Linked Server <%= name %> >>>'
	EXEC sp_dropserver '<%= name %>', 'droplogins'
END
go

PRINT '<<< ADDING Linked Server <%= name %> >>>'

EXEC sp_addlinkedserver 
	'<%= name %>'
	, @srvproduct = '<%= db_server %>' 
	, @provider = '<%= provider %>' 
	, @datasrc = '<%= db_server %>' 
	, @catalog = '<%= db_name %>' 
go

EXEC sp_addlinkedsrvlogin 
	@rmtsrvname = '<%= name %>'
	, @USEself = 'FALSE'
	, @locallogin = NULL
	, @rmtUSEr = '<%= login_name %>'
	, @rmtpassword = '<%= password %>'
go
	
EXEC sp_serveroption '<%= name %>', 'collation compatible', 'false' 
EXEC sp_serveroption '<%= name %>', 'data access', 'true' 
EXEC sp_serveroption '<%= name %>', 'rpc out', 'true' 
EXEC sp_serveroption '<%= name %>', 'rpc', 'false' 
EXEC sp_serveroption '<%= name %>', 'USE remote collation', 'true' 
EXEC sp_serveroption '<%= name %>', 'collation name', 'null' 
EXEC sp_serveroption '<%= name %>', 'connect timeout', <%= connection_timeout %>
EXEC sp_serveroption '<%= name %>', 'query timeout', <%= query_timeout %>
go

IF EXISTS (SELECT * FROM master.dbo.sysservers WHERE srvname='<%= name %>')
BEGIN
	PRINT '<<< CREATED Linked Server <%= name %> >>>'
END
ELSE
BEGIN
	PRINT '<<< FAILED CREATED Linked Server <%= name %> >>>'
END
go

DBCC TRACEON(7300, 3604)
PRINT '<<< TESTING Linked Server <%= name %> >>>'

IF (SELECT 1 FROM OPENQUERY ([<%= name %>], 'SELECT 1')) <> 1
	PRINT '<<< Linked Server <%= name %> FAILED >>>'
ELSE
	PRINT '<<< Linked Server <%= name %> SUCCEEDED >>>'
go

