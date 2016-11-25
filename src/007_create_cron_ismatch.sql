SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cron_ismatch](@minute VARCHAR(70),
	@hour VARCHAR(40), @dayofmonth VARCHAR(30),
	@month VARCHAR(30), @dayofweek VARCHAR(30),
	@year VARCHAR(255),
	@date DATETIME)
RETURNS BIT
AS
BEGIN
	IF dbo.cron_isbasicmatch(@minute, DATEPART(MINUTE, @date)) = 0
		RETURN 0
	IF dbo.cron_isbasicmatch(@hour, DATEPART(HOUR, @date)) = 0
		RETURN 0
	IF dbo.cron_matchesdayofmonth(@dayofmonth, @date) = 0
		RETURN 0
	IF dbo.cron_matchesmonth(@month, MONTH(@date)) = 0
		RETURN 0
	IF dbo.cron_matchesdayofweek(@dayofweek, @date) = 0
		RETURN 0
	IF dbo.cron_isbasicmatch(@year, YEAR(@date)) = 0
		RETURN 0
	RETURN 1;	
END