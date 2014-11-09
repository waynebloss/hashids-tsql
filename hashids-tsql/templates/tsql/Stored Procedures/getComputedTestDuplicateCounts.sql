CREATE PROCEDURE [dbo].[getComputedTestDuplicateCounts]
	
AS
BEGIN
	
	SELECT
		SUM(IsNull(csdupe.[Count], 0)) as [CaseSensitiveDuplicates],
		SUM(IsNull(cidupe.[Count], 0)) as [CaseInsensitiveDuplicates]

	FROM [dbo].[ComputedTest] t
	LEFT JOIN (
		-- Find Case Sensitive Duplicates
		SELECT HashId, count(*) as [Count]
		FROM [dbo].[ComputedTest]
		GROUP BY HashId
		HAVING COUNT(*) > 1
	) as csdupe ON t.HashId = csdupe.HashId
	LEFT JOIN (
		-- Find Case Insensitive Duplicates
		SELECT HashId COLLATE sql_latin1_general_cp1_ci_as as [HashId], count(*) as [Count]
		FROM [dbo].[ComputedTest]
		GROUP BY HashId COLLATE sql_latin1_general_cp1_ci_as
		HAVING COUNT(*) > 1
	) cidupe ON t.HashId = cidupe.HashId

END