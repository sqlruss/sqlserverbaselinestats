CREATE TABLE [Queues].[CounterData]
(
[ID] [bigint] NOT NULL IDENTITY(1, 1),
[ServerNameID] [smallint] NOT NULL,
[SampleDateID] [int] NOT NULL,
[CounterGroupID] [smallint] NULL,
[CounterNameID] [smallint] NOT NULL,
[CounterValue] [decimal] (18, 5) NULL
)
WITH
(
DATA_COMPRESSION = ROW
)
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [PK_CounterData_ID] PRIMARY KEY NONCLUSTERED  ([ID])
GO
CREATE CLUSTERED INDEX [CLIX_CounterData_SampleDateID] ON [Queues].[CounterData] ([SampleDateID]) WITH (DATA_COMPRESSION = ROW)
GO
CREATE NONCLUSTERED INDEX [IX_CounterData_SampleDateID] ON [Queues].[CounterData] ([SampleDateID])
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [UC_CounterData_ServerNameID_SampleDateID_CounterGroupID_CounterNameID] UNIQUE NONCLUSTERED  ([ServerNameID], [SampleDateID], [CounterGroupID], [CounterNameID])
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [FK_CounterGroupID] FOREIGN KEY ([CounterGroupID]) REFERENCES [Queues].[CounterGroup] ([CounterGroupID])
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [FK_CounterNameID] FOREIGN KEY ([CounterNameID]) REFERENCES [Queues].[CounterName] ([CounterNameID])
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [FK_SampleDateID] FOREIGN KEY ([SampleDateID]) REFERENCES [Queues].[SampleDate] ([SampleDateID])
GO
ALTER TABLE [Queues].[CounterData] ADD CONSTRAINT [FK_ServerNameID] FOREIGN KEY ([ServerNameID]) REFERENCES [Queues].[ServerName] ([ServerNameID])
GO
