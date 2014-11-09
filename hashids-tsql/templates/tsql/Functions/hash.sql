CREATE FUNCTION [{{schema}}].[hash]
(
	@input int,
	@alphabet nvarchar(255)
)
RETURNS nvarchar(255)
WITH SCHEMABINDING
AS
BEGIN
	DECLARE
		@hash nvarchar(255) = N'',
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