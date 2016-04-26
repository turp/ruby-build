USE <%= db.name %>
GO
DBCC SHRINKDATABASE (<%= db.name %>, 0) WITH NO_INFOMSGS
GO
