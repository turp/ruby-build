
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[SchemaVersion]') AND type in (N'U'))
BEGIN
	
	CREATE TABLE dbo.SchemaVersion (
		[Version] int NOT NULL,
		Script nvarchar(250) NOT NULL,
		ScriptRunDate datetime NOT NULL,
		SchemaName VARCHAR(25) NOT NULL CONSTRAINT DF_SchemaVersion_SchemaName DEFAULT 'dbo',
	 CONSTRAINT [PK_Schema_Version] PRIMARY KEY CLUSTERED (SchemaName ASC, [Version] ASC)
	)
END

IF NOT EXISTS (
		SELECT *
		FROM INFORMATION_SCHEMA.COLUMNS
		WHERE TABLE_NAME = 'SchemaVersion'
			AND COLUMN_NAME = 'SchemaName'
		)
BEGIN
	ALTER TABLE SchemaVersion ADD [SchemaName] VARCHAR(25) NOT NULL CONSTRAINT DF_SchemaVersion_SchemaName DEFAULT 'dbo'
END

IF  EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SchemaVersion]') AND name = N'PK_Version')
BEGIN
	ALTER TABLE [dbo].[SchemaVersion] DROP CONSTRAINT [PK_Version]
END

IF  NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[SchemaVersion]') AND name = N'PK_Schema_Version')
BEGIN
	ALTER TABLE [dbo].[SchemaVersion] ADD  CONSTRAINT [PK_Schema_Version] PRIMARY KEY CLUSTERED 
		(
			[SchemaName] ASC,
			[Version] ASC
		)
END
GO

IF NOT EXISTS (SELECT 1 FROM SchemaVersion WHERE [Version]=0 AND SchemaName='dbo')
BEGIN
	INSERT  INTO SchemaVersion ( [Version], Script, ScriptRunDate, SchemaName ) VALUES  ( 0, 'N/A', GETDATE(), 'dbo' )
END

GO

