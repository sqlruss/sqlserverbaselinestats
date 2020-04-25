SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [Queues].[DeleteCounter]

AS
BEGIN TRY

SET NOCOUNT ON;
SET XACT_ABORT ON;

/*Trim metric history*/

DELETE	[Queues].[CounterData]
FROM	[Queues].[CounterData] AS C
		JOIN [Queues].[SampleDate] AS T ON C.[SampleDateID] = T.[SampleDateID]
WHERE	T.[SampleDate] < GETDATE()-60

DELETE	[Waits].[WaitStats]
FROM	[Waits].[WaitStats] AS C
		JOIN [Queues].[SampleDate] AS T ON C.[SampleDateID] = T.[SampleDateID]
WHERE	T.[SampleDate] < GETDATE()-90

DELETE	[dbo].[DiskSpace]
FROM	[dbo].[DiskSpace] AS C
		JOIN [Queues].[SampleDate] AS T ON C.[SampleDateID] = T.[SampleDateID]
WHERE	T.[SampleDate] < GETDATE()-90

DELETE	[Queues].[SampleDate]
FROM	[Queues].[SampleDate] AS T
WHERE	T.[SampleDate] < GETDATE()-90

END TRY


BEGIN CATCH
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   RETURN 55555
END CATCH

GO
