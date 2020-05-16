SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE error_handler_sp 
AS
/*===============================
http://www.sommarskog.se/error_handling/Part1.html
http://www.sommarskog.se/copyright.html
===============================*/
BEGIN
    DECLARE @errmsg nvarchar(2048),
            @severity tinyint,
            @state tinyint,
            @errno int,
            @proc sysname,
            @lineno int

    SELECT  @errmsg = error_message(), 
            @severity = error_severity(),
            @state  = error_state(), 
            @errno = error_number(),
            @proc   = error_procedure(), 
            @lineno = error_line()

    IF @errmsg NOT LIKE '***%'
    BEGIN
            SELECT @errmsg = '*** ' + coalesce(quotename(@proc), '<dynamic SQL>') + 
            ', Line ' + ltrim(str(@lineno)) + '. Errno ' + 
            ltrim(str(@errno)) + ': ' + @errmsg
    END
    RAISERROR('%s', @severity, @state, @errmsg)
END
GO