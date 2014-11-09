CREATE FUNCTION [{{schema}}].[hashA]
(
	@input int,
	@alphabet varchar(255)
)
RETURNS varchar(255)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE
		@hash varchar(255) = '',
		@alphabetLength int = LEN(@alphabet),
		@pos int;

	WHILE 1 = 1 BEGIN
		SET @pos = @input % @alphabetLength;
		SET @hash = SUBSTRING(@alphabet, @pos + 1, 1) + @hash;
		SET @input = CAST((@input / @alphabetLength) as int);
		IF @input <= 0
			BREAK;
	END

	RETURN @hash;
END