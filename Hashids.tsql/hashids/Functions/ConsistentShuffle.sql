CREATE FUNCTION [hashids].[ConsistentShuffle]
(
	@alphabet varchar(255),
	@salt varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	
	-- IsNullorWhitespace?
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
		@temp varchar(1);

	WHILE @i > 0 BEGIN
		
		SELECT
			@v = @v % @ls,
			@n = ASCII(SUBSTRING(@salt, @v + 1, 1)),
			@p = @p + @n,
			@j = (@n + @v + @p) % @i,
			@temp = SUBSTRING(@alphabet, @j + 1, 1),

			@alphabet = 
				SUBSTRING(@alphabet, 1, @j) + 
				SUBSTRING(@alphabet, @i + 1, 1) + 
				SUBSTRING(@alphabet, @j + 2, 255),

			@alphabet = 
				SUBSTRING(@alphabet, 1, @i) + 
				@temp + 
				SUBSTRING(@alphabet, @i + 2, 255),

			@i = @i - 1,
			@v = @v + 1;

	END -- WHILE

	RETURN @alphabet;

END
