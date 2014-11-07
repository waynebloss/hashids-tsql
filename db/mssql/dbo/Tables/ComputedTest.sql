CREATE TABLE [dbo].[ComputedTest] (
    [Id]     INT           IDENTITY (1, 1) NOT NULL,
    [HashId] AS            ([hashids].[encodeId]([Id]) collate sql_latin1_general_cp1_cs_as) PERSISTED,
    [Name]   VARCHAR (255) NULL,
    CONSTRAINT [PK_ComputedTest] PRIMARY KEY CLUSTERED ([Id] ASC)
);



