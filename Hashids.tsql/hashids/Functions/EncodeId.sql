CREATE FUNCTION [hashids].[EncodeId]
(
	@number int
)
RETURNS varchar(255)
AS
BEGIN
	-- Options Data
	DECLARE
		@salt varchar(255) = 'CE6E160F053C41518582EA36CE9383D5',
		@alphabet varchar(255) = 'NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3',
		@seps varchar(255) = 'CuHciSFTtIfUhs',
		@guards varchar(255) = '49JY';

	-- Working Data
	DECLARE
		@numbersHashInt int = @number % 100,
		@lottery char(1),
		@buffer varchar(255),
		@last varchar(255),
		@ret varchar(255);

	SELECT
		@lottery = SUBSTRING(@alphabet, (@numbersHashInt % LEN(@alphabet)) + 1, 1),
		@ret = @lottery,
		@buffer = @lottery + @salt + @alphabet;

	SELECT
		@alphabet = [hashids].[ConsistentShuffle](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));

	SELECT
		@last = [hashids].[Hash](@number, @alphabet),
		@ret = @ret + @last;

	RETURN @ret;
END
