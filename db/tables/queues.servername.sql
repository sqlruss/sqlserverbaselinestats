CREATE TABLE [Queues].[ServerName]
(
[ServerNameID] [smallint] NOT NULL IDENTITY(1, 1),
[ServerName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[Environment] [tinyint] NULL,
[IsMonitored] [bit] NULL CONSTRAINT [DF_ServerName_IsMonitored] DEFAULT ((0)),
[IsCompatible] [bit] NULL
)
GO
ALTER TABLE [Queues].[ServerName] ADD CONSTRAINT [PK_ServerName_ServerID] PRIMARY KEY CLUSTERED  ([ServerNameID])
GO
