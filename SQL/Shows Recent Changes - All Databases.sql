/*
    Simple query to check when all databases in a SQL Server instance were last updated.
    Written to check if an unknown instance was in use or not during a server migration.

    Author: Chris Higham
    Date: 15/10/2025
*/
EXEC sp_MSforeachdb '
    IF ''?'' NOT IN (''master'', ''tempdb'', ''model'', ''msdb'')
        USE [?];
        SELECT DB_NAME() AS DatabaseName, 
               name AS ObjectName, 
               type_desc AS ObjectType,
               modify_date AS LastModifiedDate
        FROM sys.objects
        WHERE type IN (''U'', ''P'')
        ORDER BY modify_date desc;
'