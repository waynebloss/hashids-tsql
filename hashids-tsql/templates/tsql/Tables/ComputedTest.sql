CREATE TABLE [dbo].[ComputedTest] (
    [Id]     INT           IDENTITY (1, 1) NOT NULL,
    [HashId] AS            ([{{schema}}].[encode1]([Id]) collate sql_latin1_general_cp1_cs_as) PERSISTED,
    [Name]   NVARCHAR (255) NULL,
    CONSTRAINT [PK_ComputedTest] PRIMARY KEY CLUSTERED ([Id] ASC)
);