CREATE FUNCTION [hashids].[Encode]
(
	@value int
)
RETURNS varchar(255)
AS
BEGIN
	DECLARE
		@alphabet varchar(255) = 'NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3',
		@seps varchar(255) = 'CuHciSFTtIfUhs',
		@guards varchar(255) = '49JY',
		@minHashLength int = 0;

	RETURN '';
END
