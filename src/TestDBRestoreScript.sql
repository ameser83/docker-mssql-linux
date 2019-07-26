USE [master]

RESTORE DATABASE [TestDB]
FROM DISK = '/usr/src/app/TestDB.bak' 
WITH 
	 MOVE 'TestDB' TO '/var/opt/mssql/data/TestDB.mdf',
	 MOVE 'TestDB_Log' TO '/var/opt/mssql/data/TestDB_Log.ldf'