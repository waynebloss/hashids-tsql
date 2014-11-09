CREATE FUNCTION [{{schema}}].[consistentShuffle]
(
	@alphabet nvarchar(255),
	@salt nvarchar(255)
)
RETURNS nvarchar(255)
WITH SCHEMABINDING
AS
BEGIN
	
	-- Null or Whitespace?
	IF @salt IS NULL OR LEN(LTRIM(RTRIM(@salt))) = 0 BEGIN
		RETURN @alphabet;
	END

	DECLARE
		@ls int = LEN(@salt),
		@i int = LEN(@alphabet) - 1,
		@v int = 0,
		@p int = 0, 
		@n int = 0,
		@j int = 0,
		@temp nchar(1);

	WHILE @i > 0 BEGIN
		
		SET @v = @v % @ls;
		SET @n = UNICODE(SUBSTRING(@salt, @v + 1, 1));
		SET @p = @p + @n;
		SET @j = (@n + @v + @p) % @i;
		SET @temp = SUBSTRING(@alphabet, @j + 1, 1);
		SET @alphabet = 
				SUBSTRING(@alphabet, 1, @j) + 
				SUBSTRING(@alphabet, @i + 1, 1) + 
				SUBSTRING(@alphabet, @j + 2, 255);
		SET @alphabet = 
				SUBSTRING(@alphabet, 1, @i) + 
				@temp + 
				SUBSTRING(@alphabet, @i + 2, 255);
		SET @i = @i - 1;
		SET @v = @v + 1;

	END -- WHILE

	RETURN @alphabet;

END
GO

