RAISERROR('Create function: [dbo].[ufn_getObjectQuoteName]', 10, 1) WITH NOWAIT
GO
IF  EXISTS (SELECT * FROM sysobjects WHERE id = OBJECT_ID('[dbo].[ufn_getObjectQuoteName]') AND xtype in (N'FN', N'IF', N'TF', N'FS', N'FT'))
DROP FUNCTION [dbo].[ufn_getObjectQuoteName]
GO

DECLARE @SQLMajorVersion [int]
SELECT @SQLMajorVersion = REPLACE(LEFT(ISNULL(CAST(SERVERPROPERTY('ProductVersion') AS [varchar](32)), ''), 2), '.', '') 


DECLARE @queryToRun [nvarchar](4000)

SET @queryToRun = '
CREATE FUNCTION [dbo].[ufn_getObjectQuoteName]
(		
	@objectName	[nvarchar](' + CASE WHEN @SQLMajorVersion>8 THEN 'max' ELSE '4000' END + '),
	@quoteFor	[nvarchar](8) = NULL /* possible values: quoted, sql, xml, undo-xml, filepath, filename */
)
RETURNS [nvarchar](' + CASE WHEN @SQLMajorVersion>8 THEN 'max' ELSE '4000' END + ')
/* WITH ENCRYPTION */
AS

-- ============================================================================
-- Copyright (c) 2004-2017 Dan Andrei STEFAN (danandrei.stefan@gmail.com)
-- ============================================================================
-- Author			 : Dan Andrei STEFAN
-- Create date		 : 2004-2017
-- Module			 : Database Analysis & Performance Monitoring
-- ============================================================================

begin
	DECLARE @quoteName [nvarchar](' + CASE WHEN @SQLMajorVersion>8 THEN 'max' ELSE '4000' END + ')

	IF @quoteFor IS NULL OR @quoteFor=''quoted''
		SET @quoteName = N''['' + REPLACE(@objectName, N'']'', N'']]'') + N'']''
	IF @quoteFor = ''sql'' 
		SET @quoteName = REPLACE(@objectName, N'''''''', N'''''''''''')
	IF @quoteFor = ''xml'' 
		begin
			SET @quoteName = @objectName
			SET @quoteName = REPLACE(@quoteName, N''&'', N''&amp;'')
			SET @quoteName = REPLACE(@quoteName, N''<'', N''&lt;'')
			SET @quoteName = REPLACE(@quoteName, N''>'', N''&gt;'')
			SET @quoteName = REPLACE(@quoteName, N'''''''', N''&apos;'')
			SET @quoteName = REPLACE(@quoteName, N''"'', N''&quot;'')
		end
	IF @quoteFor = ''undo-xml'' 
		begin
			SET @quoteName = @objectName
			SET @quoteName = REPLACE(@quoteName, N''&amp;'', N''&'')
			SET @quoteName = REPLACE(@quoteName, N''&lt;'', N''<'')
			SET @quoteName = REPLACE(@quoteName, N''&amp;lt;'', N''<'')
			
			SET @quoteName = REPLACE(@quoteName, N''&gt;'', N''>'')
			SET @quoteName = REPLACE(@quoteName, N''&amp;gt;'', N''>'')

			SET @quoteName = REPLACE(@quoteName, N''&apos;'', N'''''''')
			SET @quoteName = REPLACE(@quoteName, N''&amp;apos;'', N'''''''')

			SET @quoteName = REPLACE(@quoteName, N''&quot;'', N''"'')
			SET @quoteName = REPLACE(@quoteName, N''&amp;quot;'', N''"'')
		end
	IF @quoteFor=''filepath''
		begin
			SET @quoteName = @objectName
			SET @quoteName = REPLACE(@quoteName, N'''''''', N'''''''''''')
			SET @quoteName = SUBSTRING(@quoteName, 1, 2) + REPLACE(REPLACE(REPLACE(REPLACE(SUBSTRING(@quoteName, 3, LEN(@quoteName)), N''<'', N''_''), N''>'', N''_''), N'':'', N''_''), N''"'', N''_'')
		end
	IF @quoteFor=''filename''
		begin
			SET @quoteName = @objectName
			SET @quoteName = REPLACE(@quoteName, N'''''''', N'''''''''''')
			SET @quoteName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@quoteName, N''<'', N''_''), N''>'', N''_''), N'':'', N''_''), N''"'', N''_''), N''\'', N''_''), N''/'', N''_'')
		end

	RETURN @quoteName
end'

EXEC sp_executesql  @queryToRun
GO



