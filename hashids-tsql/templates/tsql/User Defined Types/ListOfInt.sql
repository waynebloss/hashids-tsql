CREATE TYPE [hashids].[ListOfInt] AS TABLE (
    [Id]    INT IDENTITY (1, 1) NOT NULL,
    [Value] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC));

