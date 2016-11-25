SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cron_matchesdayofweek](@expression VARCHAR(70), @date DATETIME)
RETURNS BIT
AS
BEGIN
	DECLARe @dwk AS INT = DATEPART(WEEKDAY, @date) - 1;
	IF(dbo.cron_isbasicmatch(@expression, @dwk) = 1)
		RETURN 1
	IF (CHARINDEX('L', @expression, 1) > 0)
	BEGIN
		-- we are getting the last day of week of the month e.g. last monday, last wednesday etc
		-- we can ignore anything before end of day 7 days ago. The idea is 7 days from now is the
		-- same day of week therefore the last nth day of the week is the actual last day
		DECLARE @endmonth AS DATE = EOMONTH(@date);
		DECLARE @sevendaysb4 AS DATE = CONVERT(DATE, DATEADD(DAY, -7, @endmonth));
		IF(@date <= @sevendaysb4)
			RETURN 0;

		--must be 0-6.
		DECLARE @weekday AS INT = CONVERT(INT, SUBSTRING(@expression, 1, LEN(@expression)-1));
		-- if we are same day as end month check our weekday is the expected one
		IF (DATEPART(DAY, @date) = DATEPART(DAY, @endmonth))
			RETURN IIF(@dwk = @weekday, 1, 0)

		-- different day from endmonth, definitely a candidate
		-- we get how many days we need to walk back to end up
		-- on a particular day of the week
		-- if we are on a sunday(0) and we need a friday(5)
		-- then all we need to do is (0-5)+7 = 2 i.e. 2 days back
		-- the formula can be changed to -7+(5-0) = -2 
		DECLARE @endmonth_dow AS INT = DATEPART(WEEKDAY, @endmonth) -1;
		DECLARE @diff AS INT = -7 + (@weekday - @endmonth_dow);

		DECLARE @req_date AS DATETIME = DATEADD(DAY, @diff, @endmonth)
		IF(DATEPART(day, @date) = DATEPART(day, @req_date))
			RETURN 1;
	END
	ELSE IF (CHARINDEX('#', @expression, 1) > 0)
	BEGIN
		-- we are getting the 1st-4th day of week for a month--must be 0-6.
		DECLARE @expectedweekday AS INT = CONVERT(INT, left(@expression, 1)) + 1;
		-- the n is between 1-5 and is after the #
		DECLARE @nth AS INT = CONVERT(INT, right(@expression, 1));
		DECLARE @add AS INT = (@nth - 1) * 7;

		DECLARE @startmonth AS DATE = DATEFROMPARTS(YEAR(@date), MONTH(@date), 1);
		DECLARE @startweekday AS INT = DATEPART(WEEKDAY, @startmonth);
		DECLARE @expected AS DATETIME = DATEADD(DAY, @add, @startmonth);
		
		IF(@startweekday = @expectedweekday)
		BEGIN
			RETURN IIF(DATEPART(DAY, @date) = DATEPART(DAY, @expected), 1, 0)
		END

		DECLARE @startdiff AS INT = IIF(@expectedweekday > @startweekday, @expectedweekday - @startweekday, 7 - (@startweekday-@expectedweekday));
		SET @expected = DATEADD(DAY, @startdiff, @startmonth); -- the 1st week day
		SET @expected = DATEADD(DAY, @add, @expected); -- add the diff
		RETURN IIF(DATEPART(DAY, @date) = DATEPART(DAY, @expected), 1, 0)
	END
	RETURN 0;
END