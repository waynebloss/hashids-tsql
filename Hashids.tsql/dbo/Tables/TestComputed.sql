CREATE TABLE [dbo].[TestComputed] (
    [Id]     INT           IDENTITY (1, 1) NOT NULL,
    [hashId] AS            ([hashids].[EncodeId]([Id]) collate sql_latin1_general_cp1_cs_as) PERSISTED,
    [Name]   VARCHAR (255) NULL,
    CONSTRAINT [PK_TestComputed] PRIMARY KEY CLUSTERED ([Id] ASC)
);

