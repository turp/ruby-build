SET NOCOUNT ON
USE master

DECLARE @strSQL varchar(255)

CREATE table #tmpUsers(
	spid int,
	eid int,
	status varchar(30),
	loginname varchar(50),
	hostname varchar(50),
	blk int,
	dbname varchar(50),
	cmd varchar(30),
	request_id int
)

INSERT INTO #tmpUsers EXEC sp_who

DECLARE LoginCursor CURSOR
READ_ONLY FOR 
SELECT spid
FROM #tmpUsers 
WHERE dbname = '<%= name %>'
AND spid != @@spid

DECLARE @spid varchar(10)
OPEN LoginCursor

FETCH NEXT FROM LoginCursor INTO @spid

WHILE (@@fetch_status <> -1)
BEGIN
	IF (@@fetch_status <> -2)
	BEGIN
		IF EXISTS (select * from master..sysprocesses WHERE spid = @spid)
		BEGIN
			SET @strSQL = 'KILL ' + @spid
			EXEC (@strSQL)
		END
	END
	FETCH NEXT FROM LoginCursor INTO @spid
END

CLOSE LoginCursor
DEALLOCATE LoginCursor

DROP table #tmpUsers
