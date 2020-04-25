CREATE TABLE [dbo].[InstanceInfo]
(
[InstanceInfoID] [int] NOT NULL IDENTITY(1, 1),
[InstanceInfoDate] [datetime] NOT NULL CONSTRAINT [DF_InstanceInfo_InstanceInfoDate] DEFAULT (getdate()),
[Description] [nvarchar] (100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLInstanceName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[ComputerNamePhysicalNetBIOS] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[IsClustered] [bit] NULL,
[SQLProductVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLProductLevel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLEdition] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[SQLInstallDate] [datetime] NULL,
[SQLServiceLastRestart] [datetime] NULL,
[Upgrade] [bit] NULL
)
GO
CREATE CLUSTERED INDEX [IX_InstanceInfo_ComputerNamePhysicalNetBIOS] ON [dbo].[InstanceInfo] ([ComputerNamePhysicalNetBIOS])
GO
