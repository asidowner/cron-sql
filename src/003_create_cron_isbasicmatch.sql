SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[cron_isbasicmatch](@expression VARCHAR(2000), @value INT)
RETURNS BIT
AS
BEGIN
	IF(@expression = '*')
		RETURN 1
	IF(CHARINDEX('-', @expression, 1) > 0 and CHARINDEX(',', @expression, 1) > 0)
	    begin
            DECLARE @tmptbl TABLE ([result] INT)

	        INSERT @tmptbl(result)
	        SELECT value, [dbo].[cron_isbasicmatch](@value) FROM string_split(@expression,',')

	        RETURN IIF((SELECT top 1 1 FROM @tmptbl WHERE [result] = 1) = 1, 1, 0)
        end
	IF(CHARINDEX('-', @expression, 1) > 0)
		RETURN dbo.cron_isvalueinrange(@expression, @value)
	IF(CHARINDEX(',', @expression, 1) > 0)
		RETURN dbo.cron_isvaluemember(@expression, @value)
	IF(ISNUMERIC(@expression) = 1)
		RETURN IIF(CONVERT(INT, @expression) = @value, 1, 0)
	RETURN 0;
END