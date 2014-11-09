CREATE FUNCTION [{{schema}}].[encodeSplit] (
	@input nvarchar(max),
	@delim nvarchar(128) = NULL
)
RETURNS nvarchar(255)
WITH SCHEMABINDING
AS
BEGIN
	SET @delim = IsNull(@delim, N',');

	DECLARE
		@list as [{{schema}}].[ListOfInt]
	DECLARE
		@item nvarchar(4000),
		@itemList nvarchar(max),
		@delimIndex int

	SET @itemList = @input
	SET @delimIndex = CHARINDEX(@delim, @itemList, 0)

	WHILE (@delimIndex != 0) BEGIN
		SET @item = SUBSTRING(@itemList, 0, @delimIndex)
		INSERT INTO @list([Value]) VALUES(CAST(@item as int))

		-- Set @itemList = @itemList minus one less item
		SET @itemList = SUBSTRING(@itemList, @delimIndex+1, LEN(@itemList)-@delimIndex)
		SET @delimIndex = CHARINDEX(@delim, @itemList, 0)
	END

	IF @item IS NOT NULL BEGIN -- At least one delimiter was encountered in @input
		SET @item = @itemList
		INSERT INTO @list([Value]) VALUES(CAST(@item as int))
	END ELSE BEGIN
		-- No delimiters were encountered in @input, so just return @input
		INSERT INTO @list([Value]) VALUES(CAST(@input as int))
	END

	RETURN [{{schema}}].[encodeList](@list);
END