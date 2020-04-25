CREATE TABLE [Queues].[CounterGroup]
(
[CounterGroupID] [smallint] NOT NULL IDENTITY(1, 1),
[CounterGroup] [varchar] (200) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
ALTER TABLE [Queues].[CounterGroup] ADD CONSTRAINT [PK_CounterGroup_CounterGroupID] PRIMARY KEY CLUSTERED  ([CounterGroupID])
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_CounterGroup_CounterGroup] ON [Queues].[CounterGroup] ([CounterGroup])
GO
