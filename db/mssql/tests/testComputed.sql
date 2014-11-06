/*
INSERT INTO [dbo].[TestComputed]([Name])
SELECT 'Item ' + seqInt.ivc
FROM [WS01].dbo.seqInt
WHERE
	seqInt.i BETWEEN 1 AND 10000
*/

/*
SELECT *
FROM dbo.TestComputed
INNER JOIN (

SELECT hashId COLLATE sql_latin1_general_cp1_ci_as as [hashId], count(*) as [count]
FROM dbo.TestComputed
group by hashId COLLATE sql_latin1_general_cp1_ci_as
having count(*) > 1

) as dupe ON TestComputed.hashId = dupe.hashId
ORDER BY TestComputed.hashId
*/

SELECT distinct hashId
FROM dbo.TestComputed
