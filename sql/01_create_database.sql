/*
  Sistema de Gestion Notarial y Juridica
  Script 01: Creacion de base de datos y esquema
  Motor: SQL Server (SSMS 22.7.0)
*/
SET NOCOUNT ON;
GO

IF DB_ID(N'NotariaJuridica') IS NOT NULL
BEGIN
    ALTER DATABASE NotariaJuridica SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NotariaJuridica;
END
GO

CREATE DATABASE NotariaJuridica
    COLLATE SQL_Latin1_General_CP1_CI_AS;
GO

USE NotariaJuridica;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'notaria')
    EXEC(N'CREATE SCHEMA notaria AUTHORIZATION dbo;');
GO

PRINT N'Base de datos NotariaJuridica y esquema notaria creados correctamente.';
GO