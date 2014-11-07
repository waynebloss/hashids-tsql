CREATE PROCEDURE [dbo].[testComputedColumns]
	@rows int = NULL,
	@start int = NULL
AS
BEGIN
	
	SELECT
		@rows = IsNull(@rows, 10000),
		@start = IsNull(@start, 1)
	
	IF @rows > (SELECT COUNT(*) FROM [dbo].[Number]) BEGIN
		SELECT 'Not enough rows in table [dbo].[Number].' [Error]
		RETURN 0;
	END

	-- Insert new rows into the table.
	TRUNCATE TABLE [dbo].[ComputedTest]

	INSERT INTO [dbo].[ComputedTest]([Name])
	SELECT 'Item ' + n.ia
	FROM [dbo].[Number] n
	WHERE
		n.i >= @start AND (n.i + @start) < @rows
	
	-- Check for collisions.
	SELECT
		t.*,
		csdupe.[Count] as [CaseSensitiveDuplicates]
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
	ORDER BY
		csdupe.[Count] DESC,
		t.Id ASC

END