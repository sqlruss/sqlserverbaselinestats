SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE VIEW [Queues].[CounterValues]
AS

SELECT	C.ID,
		S.ServerNameID,
		S.ServerName,
		D.SampleDateID, 
		D.SampleUTCDate,
		DATEPART(WEEK,SampleUTCDate) AS [Week], 
		DATENAME(WEEKDAY,SampleUTCDate) AS [WeekDay], 
		DATEPART(HOUR,SampleUTCDate) AS [Hour],  
		G.CounterGroupID,
		G.CounterGroup, 
		N.CounterNameID,
		N.CounterName, 
		C.CounterValue
FROM	Queues.CounterData AS C
		LEFT JOIN Queues.CounterGroup AS G ON C.CounterGroupID = G.CounterGroupID
		LEFT JOIN Queues.CounterName AS N ON C.CounterNameID = N.CounterNameID
		LEFT JOIN Queues.SampleDate AS D ON C.SampleDateID = D.SampleDateID
		LEFT JOIN Queues.ServerName AS S ON C.ServerNameID = S.ServerNameID


GO
