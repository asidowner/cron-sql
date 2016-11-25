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
	IF(CHARINDEX('-', @expression, 1) > 0)
		RETURN dbo.cron_isvalueinrange(@expression, @value)
	IF(CHARINDEX(',', @expression, 1) > 0)
		RETURN dbo.cron_isvaluemember(@expression, @value)
	IF(ISNUMERIC(@expression) = 1)
		RETURN IIF(CONVERT(INT, @expression) = @value, 1, 0)
	RETURN 0;
END