CREATE PROCEDURE [dbo].[testComputedHashDuplicates]
	@start int = NULL,
	@end int = NULL
AS
BEGIN
	
	SELECT
		@start = IsNull(@start, 1),
		@end = IsNull(@end, 10000)	-- 10,000
	
	IF @end > (SELECT MAX(i) FROM [dbo].[Number])
	OR @start < (SELECT MIN(i) FROM [dbo].[Number]) BEGIN
		SELECT 'Not enough rows in table [dbo].[Number]. Execute [dbo].[seedNumberTable] once to correct this error.' [Error]
		RETURN 0;
	END

	exec [dbo].[seedComputedTestTable]
		@start=@start,
		@end=@end
	
	-- Check for collisions.
	exec [dbo].[getComputedTestDuplicateCounts]

END