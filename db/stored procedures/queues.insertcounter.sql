/****** Object:  StoredProcedure [Queues].[InsertCounter]    Script Date: 11/15/2018 10:04:11 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [Queues].[InsertCounter]
(
  @xmlString VARCHAR(MAX)
)

AS
BEGIN TRY

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @utc DATETIME2
DECLARE @xml XML;
SET @utc = GETUTCDATE();
SET @xml = @xmlString;

/*Shred xml into temp table*/
SELECT	[Timestamp] AS [SampleDate],
		SUBSTRING([Path], 3, CHARINDEX('\',[Path],3)-3) AS [Server],
		SUBSTRING([Path], CHARINDEX('\',[Path],3)+1, LEN([Path]) - CHARINDEX('\',REVERSE([Path]))+1 - (CHARINDEX('\',[Path],3)+1)) AS [CounterGroup],
		REVERSE(LEFT(REVERSE([Path]), CHARINDEX('\', REVERSE([Path]))-1)) AS [CounterName],
		CAST([CookedValue] AS float) AS [CounterValue]
INTO	#CounterDataResults
FROM
    (
	SELECT	[property].value('(./text())[1]', 'VARCHAR(200)') AS [Value],
			[property].value('@Name', 'VARCHAR(30)') AS [Attribute],
			DENSE_RANK() OVER (ORDER BY [object]) AS [Sampling]
    FROM	@xml.nodes('Objects/Object') AS mn ([object]) 
			CROSS APPLY mn.object.nodes('./Property') AS pn (property)
	) AS bp
	PIVOT (MAX(value) FOR Attribute IN ([Timestamp], [Path], [CookedValue])) AS ap

/*Add any new Server*/
INSERT	Queues.ServerName (ServerName)
SELECT	DISTINCT UPPER(R.[Server])
FROM	#CounterDataResults AS R
		LEFT JOIN Queues.ServerName AS S ON R.[Server] = S.[ServerName] 
WHERE	S.[ServerName] IS NULL

/*Add any new CounterGroup*/
INSERT	Queues.CounterGroup (CounterGroup)
SELECT	DISTINCT R.CounterGroup
FROM	#CounterDataResults AS R
		LEFT JOIN Queues.CounterGroup AS G ON R.CounterGroup = G.CounterGroup 
WHERE	G.CounterGroup IS NULL

/*Add any new CounterName*/
INSERT	Queues.CounterName (CounterName)
SELECT	DISTINCT R.CounterName
FROM	#CounterDataResults AS R
		LEFT JOIN Queues.CounterName AS N ON R.CounterName = N.CounterName
WHERE	N.CounterName IS NULL

/*Add any new SampleDate*/
INSERT	Queues.[SampleDate] ([SampleDate], [SampleUTCDate])
SELECT	DISTINCT R.[SampleDate], @utc
FROM	#CounterDataResults AS R
		LEFT JOIN Queues.[SampleDate] AS T ON R.[SampleDate] = T.[SampleDate]
WHERE	T.[SampleDate] IS NULL

/*Add new metrics*/
INSERT INTO [Queues].[CounterData] 
([SampleDateID], [ServerNameID], [CounterGroupID], [CounterNameID], [CounterValue])
SELECT	SampleDateID, ServerNameID, CounterGroupID, CounterNameID, CounterValue
FROM	#CounterDataResults AS D
		LEFT JOIN Queues.CounterGroup AS G ON D.CounterGroup = G.CounterGroup
		LEFT JOIN Queues.CounterName AS N ON D.CounterName = N.CounterName
		JOIN Queues.ServerName AS S ON D.[Server] = S.ServerName
		JOIN Queues.[SampleDate] AS T ON D.[SampleDate] = T.[SampleDate]

END TRY


BEGIN CATCH
   IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION
   RETURN 55555
END CATCH



GO


