-- Test
exec [dbo].[seedNumberTable] @start=1, @end=10000;
GO

exec [dbo].[testComputedHashDuplicates] @start=1, @end=10000;