﻿CREATE FUNCTION [{{schema}}].[encodeListA]
(
	@numbers [{{schema}}].[ListOfInt] READONLY
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
		@numbersHashInt int = 0,
		@lottery char(1),
		@buffer varchar(255),
		@last varchar(255),
		@ret varchar(255),
		@sepsIndex int,
		@lastId int,
		@count int = IsNull((SELECT COUNT(*) FROM @numbers), 0),
		@i int = 0,
		@id int = 0,
		@number int;

	-- Calculate numbersHashInt
	SET @lastId = IsNull((SELECT MAX([Id]) FROM @numbers), 0)
	WHILE @id < @lastId BEGIN
		SELECT TOP 1 @id = [Id], @number = [Value] FROM @numbers WHERE [Id] > @id
		SET @numbersHashInt += (@number % (@i + 100));
		SET @i += 1
	END
	
	-- Choose lottery
	SET @lottery = SUBSTRING(@alphabet, (@numbersHashInt % LEN(@alphabet)) + 1, 1);
	SET @ret = @lottery;

	-- Encode many
	SET @i = 0
	SET @id = 0
	WHILE @id < @lastId BEGIN
		SELECT TOP 1 @id = [Id], @number = [Value] FROM @numbers WHERE [Id] > @id

		SET @buffer = @lottery + @salt + @alphabet;
		SET @alphabet = [{{schema}}].[consistentShuffle](@alphabet, SUBSTRING(@buffer, 1, LEN(@alphabet)));
		SET @last = [{{schema}}].[hash](@number, @alphabet);
		SET @ret = @ret + @last;

		IF (@i + 1) < @count BEGIN
			SET @sepsIndex = @number % (ASCII(SUBSTRING(@last, 1, 1)) + @i);
			SET @sepsIndex = @sepsIndex % LEN(@seps);
			SET @ret = @ret + SUBSTRING(@seps, @sepsIndex + 1, 1);
		END

		SET @i += 1
	END

	----------------------------------------------------------------------------
	-- Enforce minHashLength
	----------------------------------------------------------------------------
	IF LEN(@ret) < @minHashLength BEGIN
		DECLARE
			@guardIndex int,
			@guard char(1),
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
			SET @alphabet = [{{schema}}].[consistentShuffle](@alphabet, @alphabet);
			SET @ret = SUBSTRING(@alphabet, @halfLength + 1, 255) + @ret + 
					SUBSTRING(@alphabet, 1, @halfLength);
			SET @excess = LEN(@ret) - @minHashLength;
			IF @excess > 0 
				SET @ret = SUBSTRING(@ret, CAST((@excess / 2) as int) + 1, @minHashLength);
		END
	END
	RETURN @ret;
END