-- Test
exec [dbo].[seedNumberTable] @start=1, @end=10000;
GO

exec [dbo].[testComputedHashDuplicates] @start=1, @end=10000;
GO

SELECT TOP 100 *
FROM [dbo].[ComputedTest];
GO

-- Javascript Generated Hashids for Comparison:
/*

{{testResults}}

*/
