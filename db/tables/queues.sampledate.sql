CREATE TABLE [Queues].[SampleDate]
(
[SampleDateID] [int] NOT NULL IDENTITY(1, 1),
[SampleDate] [datetime2] (0) NOT NULL,
[SampleUTCDate] [datetime2] (0) NULL
)
GO
ALTER TABLE [Queues].[SampleDate] ADD CONSTRAINT [PK_SampleDate_SampleDateID] PRIMARY KEY CLUSTERED  ([SampleDateID])
GO
CREATE NONCLUSTERED INDEX [IX_SampleDate_SampleDate] ON [Queues].[SampleDate] ([SampleDate])
GO
CREATE NONCLUSTERED INDEX [IX_SampleDate_SampleUTCDate] ON [Queues].[SampleDate] ([SampleUTCDate])
GO
