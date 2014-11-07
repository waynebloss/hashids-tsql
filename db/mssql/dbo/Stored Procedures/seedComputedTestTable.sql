CREATE PROCEDURE [dbo].[seedComputedTestTable]
	@rows int = NULL,
	@start int = NULL
AS
BEGIN
	
	SELECT
		@rows = IsNull(@rows, 10000),
		@start = IsNull(@start, 1)

	-- Insert new rows into the table.
	TRUNCATE TABLE [dbo].[ComputedTest]

	INSERT INTO [dbo].[ComputedTest]([Name])
	SELECT 'Item ' + n.ia
	FROM [dbo].[Number] n
	WHERE
		n.i BETWEEN @start AND (@start + @rows - 1)

END