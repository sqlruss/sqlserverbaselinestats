SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [Queues].[CounterValuesForGrafana]
AS

SELECT
		 I.SQLInstanceName AS ServerName,
        --DATEADD(HOUR,6,SampleDate) AS [Time],
        D.SampleUTCDate AS [Time],
		G.CounterGroupID,
		G.CounterGroup,
		N.CounterNameID,
		N.CounterName,        
	   CASE WHEN G.CounterGroup LIKE 'physicaldisk%'
	   THEN 'physicaldisk('+ RIGHT(G.CounterGroup,3) + '\' + N.CounterName 
	   ELSE G.CounterGroup + '\' + N.CounterName
	   END AS CounterGroupAndName,
		C.CounterValue
FROM	Queues.CounterData AS C
		 JOIN Queues.CounterGroup AS G ON C.CounterGroupID = G.CounterGroupID
		 JOIN Queues.CounterName AS N ON C.CounterNameID = N.CounterNameID
		 JOIN Queues.SampleDate AS D ON C.SampleDateID = D.SampleDateID
		 JOIN Queues.ServerName AS S ON C.ServerNameID = S.ServerNameID
	   JOIN dbo.InstanceInfo AS I ON S.ServerName = I.ComputerNamePhysicalNetBIOS
GO
