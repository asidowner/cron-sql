SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[cron_isvaluemember](@values VARCHAR(70), @value INT)
RETURNS BIT
AS
BEGIN
	-- range is specified as a-b
	-- get index of - the parse int for 
	DECLARE @res AS BIT = 0;
	SET @values = @values + ','; --make computation uniform

	;WITH v([value], [text], [index])AS(
		SELECT CONVERT(int, left(@values, CHARINDEX(',', @values, 1) -1)), 
			SUBSTRING(@values, CHARINDEX(',', @values, 1) + 1, LEN(@values)),
			0
		UNION ALL
		SELECT CONVERT(INT, LEFT(v.[text], CHARINDEX(',', v.[text], 1) - 1)), 
			SUBSTRING(v.[text], CHARINDEX(',', v.[text], 1) + 1, LEN(v.[text]))
			, v.[index] + 1
		FROM v
		WHERE LEN(v.[text]) > 0
	)

	SELECT @res = IIF(EXISTS(SELECT * FROM v WHERE v.[value] = @value), 1, 0)

	RETURN @res;
END