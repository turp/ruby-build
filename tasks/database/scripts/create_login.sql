IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = '<%= name %>')
	CREATE LOGIN [<%= name %>] WITH PASSWORD='<%= password %>', DEFAULT_LANGUAGE=[us_english], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
ALTER LOGIN [<%= name %>] WITH PASSWORD='<%= password %>'
go
ALTER LOGIN [<%= name %>] WITH DEFAULT_DATABASE=[<%= default_database %>]
GO
USE [<%= default_database %>]
go
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = '<%= name %>')
	CREATE USER [<%= name %>] FOR LOGIN [<%= name %>]
GO
EXEC sp_addrolemember 'db_owner', '<%= name %>'
GO
