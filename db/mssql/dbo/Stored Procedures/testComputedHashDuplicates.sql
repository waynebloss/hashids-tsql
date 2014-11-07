CREATE PROCEDURE [dbo].[testComputedHashDuplicates]
	@rows int = NULL,
	@start int = NULL
AS
BEGIN
	
	SELECT
		@rows = IsNull(@rows, 10000),
		@start = IsNull(@start, 1)
	
	IF @rows > (SELECT COUNT(*) FROM [dbo].[Number]) BEGIN
		SELECT 'Not enough rows in table [dbo].[Number]. Execute [dbo].[seedNumberTable] once to correct this error.' [Error]
		RETURN 0;
	END

	exec [dbo].[seedComputedTestTable]
		@rows=@rows,
		@start=@start
	
	-- Check for collisions.
	DECLARE
		@csCount int,
		@ciCount int

	SELECT
		@csCount = SUM(IsNull(csdupe.[Count], 0)),
		@ciCount = SUM(IsNull(cidupe.[Count], 0))
	FROM [dbo].[ComputedTest] t
	LEFT JOIN (
		-- Find Case Sensitive Duplicates
		SELECT HashId COLLATE sql_latin1_general_cp1_cs_as as [HashId], count(*) as [Count]
		FROM [dbo].[ComputedTest]
		GROUP BY HashId COLLATE sql_latin1_general_cp1_cs_as
		HAVING COUNT(*) > 1
	) as csdupe ON t.HashId = csdupe.HashId
	LEFT JOIN (
		-- Find Case Insensitive Duplicates
		SELECT HashId COLLATE sql_latin1_general_cp1_ci_as as [HashId], count(*) as [Count]
		FROM [dbo].[ComputedTest]
		GROUP BY HashId COLLATE sql_latin1_general_cp1_ci_as
		HAVING COUNT(*) > 1
	) cidupe ON t.HashId = cidupe.HashId

	SELECT
		@csCount as [CaseSensitiveDuplicates],
		@ciCount as [CaseInsensitiveDuplicates]

END