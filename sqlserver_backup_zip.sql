/**
 * Author:
 *	Graham Lyons
 * Date:
 *	2010-08-20
 * Synopsis:
 *	SQL script to backup a database and then add the backup file to a ZIP archive.
 *	Requires the WINZIP command line utility (or other command line archive program).
 */

GO
-- Set the name of the database.
DECLARE	@dbname NVARCHAR(1024)
SET	@dbname = 'EXAMPLE'

-- Set the name of the backup directory.
DECLARE	@bakdir VARCHAR(300)
SET	@bakdir = 'C:\Backup\'

-- Backup the database in a subdirectory of this.
DECLARE	@dbbakdir VARCHAR(300)
SET	@dbbakdir = 'C:\Backup\' + @dbname

-- Create the name of the backup file from the database name and the current date.
DECLARE	@bakname VARCHAR(300)
SET	@bakname = @dbname + '_backup_' + REPLACE(CONVERT(VARCHAR(20), GETDATE(), 112) + CONVERT(VARCHAR(20), GETDATE(), 108),':','')

-- Set the name of the backup file.
DECLARE	@filename VARCHAR(300)
SET	@filename = @dbbakdir + '\' + @bakname+'.bak'

-- Create the subdirectory if necessary.
EXECUTE	master.dbo.xp_create_subdir @dbbakdir

-- Backup the database.
BACKUP DATABASE @dbname
TO  DISK = @filename
WITH NOFORMAT, NOINIT,  NAME = @bakname, SKIP, REWIND, NOUNLOAD,  STATS = 10

-- Turn on the 'xp_cmdshell' function.
EXEC sp_configure 'show advanced options', 1
RECONFIGURE
EXEC sp_configure 'xp_cmdshell', 1
RECONFIGURE

-- Build the command line string to add the file to the ZIP archive.
DECLARE	@cmd VARCHAR(300)
SET	@cmd = 'wzzip -a "C:\BACKUP\'+ @bakname + '.zip" "' + @filename + '"'

-- Execute the command.
EXEC xp_cmdshell @cmd

-- Turn off the 'xp_cmdshell' function.
EXEC sp_configure 'xp_cmdshell', 0
RECONFIGURE
EXEC sp_configure 'show advanced options', 0
RECONFIGURE

GO
