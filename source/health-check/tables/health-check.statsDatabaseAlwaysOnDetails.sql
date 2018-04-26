-- ============================================================================
-- Copyright (c) 2004-2015 Dan Andrei STEFAN (danandrei.stefan@gmail.com)
-- ============================================================================
-- Author			 : Dan Andrei STEFAN
-- Create date		 : 26.05.2017
-- Module			 : Database Analysis & Performance Monitoring
-- ============================================================================

-----------------------------------------------------------------------------------------------------
--Health Check: database statistics & details
-----------------------------------------------------------------------------------------------------
RAISERROR('Create table: [health-check].[statsDatabaseAlwaysOnDetails]', 10, 1) WITH NOWAIT
GO
IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[health-check].[statsDatabaseAlwaysOnDetails]') AND type in (N'U'))
DROP TABLE [health-check].[statsDatabaseAlwaysOnDetails]
GO
CREATE TABLE [health-check].[statsDatabaseAlwaysOnDetails]
(
	[id]							[int]	 IDENTITY (1, 1)	NOT NULL,
	[catalog_database_id]			[int]			NOT NULL,
	[instance_id]					[smallint]		NOT NULL,
	[cluster_name]					[sysname]		NOT NULL,
	[ag_name]						[sysname]		NOT NULL,
	[role_desc]						[nvarchar](60)	NULL,
	[synchronization_health_desc]	[nvarchar](60)	NULL,
	[synchronization_state_desc]	[nvarchar](60)	NULL,
	[data_loss_sec]					[int]			NULL,
	[event_date_utc]				[datetime]		NOT NULL,
	CONSTRAINT [PK_statsDatabaseAlwaysOnDetails] PRIMARY KEY  CLUSTERED 
	(
		[id],
		[catalog_database_id]
	) ON [FG_Statistics_Data],
	CONSTRAINT [FK_statsDatabaseAlwaysOnDetails_catalogDatabaseNames] FOREIGN KEY 
	(
		  [catalog_database_id]
		, [instance_id]
	) 
	REFERENCES [dbo].[catalogDatabaseNames] 
	(
		  [id]
		, [instance_id]
	)
)ON [FG_Statistics_Data]
GO

CREATE INDEX [IX_statsDatabaseAlwaysOnDetails_CatalogDatabaseID] ON [health-check].[statsDatabaseAlwaysOnDetails] ([catalog_database_id], [instance_id]) ON [FG_Statistics_Index]
GO
CREATE INDEX [IX_statsDatabaseAlwaysOnDetails_InstanceID] ON [health-check].[statsDatabaseAlwaysOnDetails] ([instance_id]) ON [FG_Statistics_Index]
GO
