SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO



CREATE VIEW [dbo].[MSSQLEstateForGrafana]
AS 

    SELECT  
		  CAST(CONVERT(date, InstanceInfoDate) AS VARCHAR(20)) AS LastQueried,
		  CASE IsMonitored WHEN 1 THEN 'Yes' WHEN 0 THEN 'No' ELSE NULL END AS IsMonitored,
		  SQLInstanceName, 
		  LEFT(I.[Description],CHARINDEX(' ',I.[Description])) AS Environment,
		  REPLACE(REPLACE(I.[Description],SQLInstanceName,' '),LEFT(I.[Description],CHARINDEX(' ',I.[Description])),'') AS Pipeline,
		  CASE Upgrade WHEN 0 THEN 'Support' WHEN 1 THEN 'Upgrade' ELSE 'N/A' END AS Upgrade,
		  CASE	
			 WHEN SQLProductVersion LIKE '15.0%' THEN 'SQL Server 2019' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '14.0%' THEN 'SQL Server 2017' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '13.0%' THEN 'SQL Server 2016' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '11.0%' THEN 'SQL Server 2012' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '10.5%' THEN 'SQL Server 2008 R2' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '12.0%' THEN 'SQL Server 2014' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '10.0%' THEN 'SQL Server 2008' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '9.0%' THEN 'SQL Server 2005' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 WHEN SQLProductVersion LIKE '8.0%' THEN 'SQL Server 2000' + ' ' + SQLProductLevel + ' ' + SQLEdition + ' (' +  SQLProductVersion + ')'
			 ELSE NULL
		    END AS SQLProductVersion,
          CASE IsClustered WHEN 0 THEN 'No' WHEN 1 THEN 'Yes' ELSE NULL END AS IsClustered,
		  --CAST(IsClustered AS VARCHAR(5)) AS IsClustered,
		  CAST(CONVERT(date, SQLInstallDate) AS VARCHAR(20)) AS SQLInstalled, 
		  CAST(CONVERT(date, SQLServiceLastRestart) AS VARCHAR(20)) AS LastSQLRestart,
		  --LEFT(LastBootDate,4) +'-'+ SUBSTRING(LastBootDate,5,2) +'-'+ RIGHT(LastBootDate,2) AS LastBooted,	
		  MachineName, 
		  --IPAddress, 
		  Model,
		  CAST(CPUSockets AS VARCHAR(5)) +' Sockets, '+ 
          CAST((CASE CoresPerSocket WHEN 0 THEN 1 ELSE CoresPerSocket END) AS VARCHAR(5)) +' Core Each, '+ 
          CAST((CASE LogicalCPUPerCore WHEN 0 THEN CPUSockets ELSE LogicalCPUPerCore*CPUSockets END) AS VARCHAR(5)) + ' Logical Cores' 
          AS 'Cores',
		  CAST(MemoryGB AS VARCHAR(5)) [RAM(GB)], 
 		  WindowsVersionDescription + ' ' + WindowsProductLevel AS WindowsVersion
    FROM	   Queues.ServerName AS N 
		   JOIN dbo.InstanceInfo AS I ON N.ServerName = I.ComputerNamePhysicalNetBIOS
		   JOIN dbo.SystemInfo AS S ON N.ServerName = S.MachineName

GO
