SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE VIEW [dbo].[MonitoredInstances]
AS

	SELECT	DISTINCT I.SQLInstanceName, I.Description
	FROM	Queues.ServerName AS S 
			JOIN dbo.InstanceInfo AS I ON S.ServerName = I.ComputerNamePhysicalNetBIOS 
	WHERE	1 = 1
			AND S.IsMonitored = 1
GO
