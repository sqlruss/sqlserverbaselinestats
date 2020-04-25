CREATE TABLE [Queues].[CounterName]
(
[CounterNameID] [smallint] NOT NULL IDENTITY(1, 1),
[CounterName] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [Queues].[CounterName] ADD CONSTRAINT [PK_CounterName_CounterNameID] PRIMARY KEY CLUSTERED  ([CounterNameID]) ON [PRIMARY]
GO
