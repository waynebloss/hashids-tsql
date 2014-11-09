CREATE PROCEDURE [dbo].[listComputedTestDuplicates]
	
AS
BEGIN
	
	SELECT
		t.*,
		IsNull(csdupe.[Count], 0) as [CaseSensitiveDuplicates],
		IsNull(cidupe.[Count], 0) as [CaseInsensitiveDuplicates]
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
		IsNull(csdupe.[Count], 0) DESC,
		t.Id ASC

END