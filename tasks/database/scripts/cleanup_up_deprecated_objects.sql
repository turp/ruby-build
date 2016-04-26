DECLARE @sql varchar(max)

DECLARE c cursor for
SELECT 
 'DROP ' +  
	CASE type_desc 
		WHEN 'SQL_STORED_PROCEDURE' THEN 'PROCEDURE'
		WHEN 'VIEW' THEN 'VIEW' 
		ELSE 'FUNCTION' 
	END + ' dbo.' + name as sql
 FROM sys.objects 
WHERE create_date < DATEADD(MINUTE, -10, getdate())
AND (type_desc IN ('VIEW', 'SQL_STORED_PROCEDURE') OR type_desc LIKE '%FUNCTION%')
ORDER BY name

OPEN c
FETCH NEXT FROM c INTO @sql

WHILE (@@fetch_status = 0)
BEGIN
	PRINT '<<< ' + @sql + ' >>>'
	EXECUTE(@sql)
		
	FETCH NEXT FROM c INTO @sql
END
 
CLOSE c
DEALLOCATE c
go

