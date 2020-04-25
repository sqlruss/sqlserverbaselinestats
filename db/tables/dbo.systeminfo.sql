CREATE TABLE [dbo].[SystemInfo]
(
[SystemInfoID] [int] NOT NULL IDENTITY(1, 1),
[SystemInfoDate] [datetime] NOT NULL CONSTRAINT [DF_SystemInfo_SystemInfoDate] DEFAULT (getdate()),
[MachineName] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
[IPAddress] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Model] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[CPUSockets] [tinyint] NULL,
[CoresPerSocket] [tinyint] NULL,
[LogicalCPUPerCore] [tinyint] NULL,
[MemoryGB] [decimal] (18, 0) NULL,
[WindowsVersion] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WindowsVersionDescription] [nvarchar] (250) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WindowsProductLevel] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[WindowsInstallDate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[LastBootDate] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
[Description] [nvarchar] (50) COLLATE SQL_Latin1_General_CP1_CI_AS NULL
)
GO
