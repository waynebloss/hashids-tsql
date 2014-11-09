CREATE TYPE [{{schema}}].[ListOfBigint] AS TABLE (
    [Id]    INT IDENTITY (1, 1) NOT NULL,
    [Value] BIGINT NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC));