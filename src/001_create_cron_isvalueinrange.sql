SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cron_isvalueinrange](@range VARCHAR(10), @value INT)
returns BIT
AS
BEGIN
	-- range is specified as a-b
	-- get index of - the parse int for 
	DECLARE @indexof AS INT = charindex('-', @range, 1);
	DECLARE @start AS INT = convert(INT, substring(@range, 1, @indexof - 1));
	DECLARE @end AS INT = convert(INT, substring(@range, @indexof + 1, len(@range))); --sql server corrects length so why care
	
	RETURN iif(@value >= @start AND @value <= @end, 1, 0);
end
