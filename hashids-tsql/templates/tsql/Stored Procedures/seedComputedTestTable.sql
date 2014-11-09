CREATE PROCEDURE [dbo].[seedComputedTestTable]
	@start int = NULL,
	@end int = NULL
AS
BEGIN
	
	SELECT
		@start = IsNull(@start, 1),
		@end = IsNull(@end, 10000);	-- 10,000

	-- Insert new rows into the table.
	TRUNCATE TABLE [dbo].[ComputedTest]

	INSERT INTO [dbo].[ComputedTest]([Name])
	SELECT 'Item ' + n.ia
	FROM [dbo].[Number] n
	WHERE
		n.i BETWEEN @start AND @end

END