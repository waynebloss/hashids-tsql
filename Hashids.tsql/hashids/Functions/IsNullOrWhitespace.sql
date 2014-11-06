CREATE FUNCTION [hashids].[IsNullOrWhitespace]
(
	@value varchar(255)
)
RETURNS bit
AS
BEGIN
	
	IF @value IS NULL RETURN 1;

	IF LEN(LTRIM(RTRIM(@value))) = 0 RETURN 1;

	RETURN 0;

END
