SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cron_matchesdayofmonth](@expression VARCHAR(70), @date DATETIME)
RETURNS BIT
AS
BEGIN
	IF(dbo.cron_isbasicmatch(@expression, datepart(day, @date)) = 1)
		RETURN 1
	IF (@expression = 'L')
	BEGIN
		DECLARE @endday AS INT = DATEPART(DAY, EOMONTH(@date))
		RETURN IIF(DATEPART(DAY, @date) = @endday, 1, 0)
	END
	RETURN 0
end