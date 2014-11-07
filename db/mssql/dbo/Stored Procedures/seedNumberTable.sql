CREATE PROCEDURE [dbo].[seedNumberTable]
	@rows int = NULL,
	@withStringConversion bit = NULL
AS
BEGIN
	
	SELECT
		@rows = IsNull(@rows, 8192),
		@withStringConversion = IsNull(@withStringConversion, 1);

	TRUNCATE TABLE [dbo].[Number];
	
	-- Create 8 seed rows
	DECLARE
		@seed TABLE(i int);

	INSERT INTO @seed(i)
	VALUES(0),(1),(2),(3),(4),(5),(6),(7);

	INSERT INTO [dbo].[Number](i)
	SELECT i FROM @seed WHERE i < @rows;

	-- Multiply them by 2 until we reach @rows
	DECLARE
		@count int

	WHILE ((select count(*) from [dbo].[Number]) < @rows) BEGIN
		
		SELECT @count = (select count(*) from [dbo].[Number])

		INSERT INTO [dbo].[Number](i)
		SELECT n.i + @count
		FROM [dbo].[Number] n
		WHERE
			(n.i + @count) < @rows;

	END

	-- Pre-generate string conversions
	IF @withStringConversion = 1 BEGIN
		UPDATE [dbo].[Number]
		SET
			ia = cast(i as varchar(10)),
			iu = cast(i as nvarchar(10));
	END

END