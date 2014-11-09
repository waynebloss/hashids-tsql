﻿CREATE FUNCTION [{{schema}}].[encode2A]
(
	@number1 int,
	@number2 int
)
RETURNS varchar(255)
WITH SCHEMABINDING
AS
BEGIN
	-- Options Data - generated by hashids-tsql
	DECLARE
		@salt varchar(255) = 'CE6E160F053C41518582EA36CE9383D5',
		@alphabet varchar(255) = 'NxBvP0nK7QgWmejLzwdA6apRV25lkOqo8MX1ZrbyGDE3',
		@seps varchar(255) = 'CuHciSFTtIfUhs',
		@guards varchar(255) = '49JY',
		@minHashLength int = 0;

	-- Working Data
	DECLARE
		@numbersHashInt int,
		@lottery nchar(1),
		@buffer varchar(255),
		@last varchar(255),
		@ret varchar(255),
		@sepsIndex int;

	SET @numbersHashInt = (@number1 % 100) + (@number2 % 101);

	SET @lottery = SUBSTRING(@alphabet, (@numbersHashInt % LEN(@alphabet)) + 1, 1);
	SET @ret = @lottery;

	SET @buffer = @lottery + @salt + @alphabet;
	SET @alphabet = [{{schema}}].[consistentShuffleA](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));
	SET @last = [{{schema}}].[hashA](@number1, @alphabet);
	SET @ret = @ret + @last;

	-- Before adding @number2, add a separator
	SET @sepsIndex = @number1 % ASCII(SUBSTRING(@last, 1, 1));
	SET @sepsIndex = @sepsIndex % LEN(@seps);
	SET @ret = @ret + SUBSTRING(@seps, @sepsIndex + 1, 1);

	-- Add @number2
	SET @buffer = @lottery + @salt + @alphabet;
	SET @alphabet = [{{schema}}].[consistentShuffleA](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));
	SET @last = [{{schema}}].[hashA](@number2, @alphabet);
	SET @ret = @ret + @last;

	----------------------------------------------------------------------------
	-- Enforce minHashLength
	----------------------------------------------------------------------------
	IF LEN(@ret) < @minHashLength BEGIN
		DECLARE
			@guardIndex int,
			@guard nchar(1),
			@halfLength int,
			@excess int;
		------------------------------------------------------------------------
		-- Add first 2 guard characters
		------------------------------------------------------------------------
		SET @guardIndex = (@numbersHashInt + ASCII(SUBSTRING(@ret, 1, 1))) % LEN(@guards);
		SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
		SET @ret = @guard + @ret;
		IF LEN(@ret) < @minHashLength BEGIN
			SET @guardIndex = (@numbersHashInt + ASCII(SUBSTRING(@ret, 3, 1))) % LEN(@guards);
			SET @guard = SUBSTRING(@guards, @guardIndex + 1, 1);
			SET @ret = @ret + @guard;
		END
		------------------------------------------------------------------------
		-- Add the rest
		------------------------------------------------------------------------
		WHILE LEN(@ret) < @minHashLength BEGIN
			SET @halfLength = IsNull(@halfLength, CAST((LEN(@alphabet) / 2) as int));
			SET @alphabet = [{{schema}}].[consistentShuffleA](@alphabet, @alphabet);
			SET @ret = SUBSTRING(@alphabet, @halfLength + 1, 255) + @ret + 
					SUBSTRING(@alphabet, 1, @halfLength);
			SET @excess = LEN(@ret) - @minHashLength;
			IF @excess > 0 
				SET @ret = SUBSTRING(@ret, CAST((@excess / 2) as int) + 1, @minHashLength);
		END
	END
	RETURN @ret;
END