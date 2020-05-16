SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [Queues].[DeleteCounter]
@TrimDate DATETIME2(0)
AS
SET XACT_ABORT, NOCOUNT ON;
BEGIN TRY

	RAISERROR ('Trim metric history...', 0, 1) WITH NOWAIT;

	BEGIN TRANSACTION
		DELETE	[Queues].[CounterData]
		FROM	[Queues].[CounterData] AS C
				JOIN [Queues].[SampleDate] AS T ON C.[SampleDateID] = T.[SampleDateID]
		WHERE	T.[SampleDate] < @TrimDate
	COMMIT TRANSACTION
	BEGIN TRANSACTION
		DELETE	[Queues].[SampleDate]
		FROM	[Queues].[SampleDate] AS T
		WHERE	T.[SampleDate] < @TrimDate
	COMMIT TRANSACTION

END TRY
BEGIN CATCH
	IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	EXEC dbo.error_handler_sp
	RETURN 55555
END CATCH
GO
