CREATE FUNCTION [hashids].[Hash]
(
	@input int,
	@alphabet varchar(255)
)
RETURNS varchar(255)
AS
BEGIN
	DECLARE
		@hash varchar(255) = '',
		@alphabetLength int = LEN(@alphabet),
		@pos int = 0;

	WHILE 1 = 1 BEGIN
		SELECT
			@pos = @input % @alphabetLength,
			@hash = SUBSTRING(@alphabet, @pos + 1, 1) + @hash,
			@input = CAST((@input / @alphabetLength) as int);
		IF @input <= 0 BREAK;
	END
	
	RETURN @hash;
END
