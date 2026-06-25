/*
  Sistema de Gestion Notarial y Juridica
  Script 03: Procedimientos almacenados de negocio y auditoria
*/
SET NOCOUNT ON;
GO

USE NotariaJuridica;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER PROCEDURE notaria.sp_RegistrarAuditoria
    @id_usuario     INT,
    @tabla_afectada VARCHAR(80),
    @operacion      VARCHAR(20),
    @id_registro    VARCHAR(50),
    @detalle_xml    XML
AS
BEGIN
    SET XACT_ABORT ON;

    INSERT INTO notaria.Auditoria (
        id_usuario, tabla_afectada, operacion, id_registro, detalle_xml
    )
    VALUES (
        @id_usuario, @tabla_afectada, @operacion, @id_registro, @detalle_xml
    );
END;
GO

CREATE OR ALTER PROCEDURE notaria.sp_AbrirExpediente
    @id_cliente         INT,
    @folio_expediente   VARCHAR(30),
    @id_usuario         INT,
    @observaciones      NVARCHAR(500),
    @id_expediente      INT OUTPUT
AS
BEGIN
    DECLARE @xml XML;
    DECLARE @id_registro VARCHAR(50);

    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM notaria.Cliente WHERE id_cliente = @id_cliente AND activo = 1)
        THROW 50001, 'El cliente no existe o esta inactivo.', 1;

    IF EXISTS (SELECT 1 FROM notaria.Expediente WHERE folio_expediente = @folio_expediente)
        THROW 50002, 'El folio de expediente ya existe.', 1;

    BEGIN TRAN;

    INSERT INTO notaria.Expediente (folio_expediente, id_cliente, estado, observaciones)
    VALUES (@folio_expediente, @id_cliente, 'ABIERTO', @observaciones);

    SET @id_expediente = SCOPE_IDENTITY();
    SET @id_registro = CAST(@id_expediente AS VARCHAR(50));
    SET @xml = (
        SELECT @folio_expediente AS folio,
               @id_cliente AS id_cliente,
               'ABIERTO' AS estado
        FOR XML PATH('Expediente'), TYPE
    );

    EXEC notaria.sp_RegistrarAuditoria
        @id_usuario, 'Expediente', 'INSERT', @id_registro, @xml;

    COMMIT TRAN;
END;
GO

CREATE OR ALTER PROCEDURE notaria.sp_RegistrarVersionDocumento
    @id_documento       INT,
    @contenido_resumen  NVARCHAR(500),
    @contenido_hash     VARBINARY(MAX),
    @id_usuario         INT,
    @id_version         INT OUTPUT
AS
BEGIN
    DECLARE @ultima_version INT;
    DECLARE @nueva_version INT;
    DECLARE @hash VARBINARY(32);
    DECLARE @xml XML;
    DECLARE @id_registro VARCHAR(50);

    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM notaria.Documento WHERE id_documento = @id_documento)
        THROW 50003, 'El documento no existe.', 1;

    SELECT @ultima_version = ISNULL(MAX(numero_version), 0)
    FROM notaria.VersionDocumento
    WHERE id_documento = @id_documento;

    IF @ultima_version > 0
       AND NOT EXISTS (
            SELECT 1
            FROM notaria.VersionDocumento
            WHERE id_documento = @id_documento
              AND numero_version = @ultima_version
              AND firmado = 1
        )
        THROW 50004, 'La version vigente debe estar firmada antes de crear una nueva version.', 1;

    SET @nueva_version = @ultima_version + 1;
    SET @hash = HASHBYTES('SHA2_256', @contenido_hash);

    BEGIN TRAN;

    INSERT INTO notaria.VersionDocumento (
        id_documento, numero_version, contenido_resumen, hash_documento, firmado
    )
    VALUES (
        @id_documento, @nueva_version, @contenido_resumen, @hash, 0
    );

    SET @id_version = SCOPE_IDENTITY();
    SET @id_registro = CAST(@id_version AS VARCHAR(50));
    SET @xml = (
        SELECT @id_documento AS id_documento,
               @nueva_version AS numero_version,
               CONVERT(VARCHAR(64), @hash, 2) AS hash_hex
        FOR XML PATH('VersionDocumento'), TYPE
    );

    EXEC notaria.sp_RegistrarAuditoria
        @id_usuario, 'VersionDocumento', 'INSERT', @id_registro, @xml;

    COMMIT TRAN;
END;
GO

CREATE OR ALTER PROCEDURE notaria.sp_AplicarFirmaElectronica
    @id_version         INT,
    @id_usuario         INT,
    @certificado_serial VARCHAR(80),
    @id_firma           INT OUTPUT
AS
BEGIN
    DECLARE @hash_doc VARBINARY(32);
    DECLARE @firmado BIT;
    DECLARE @xml XML;
    DECLARE @id_registro VARCHAR(50);

    SET XACT_ABORT ON;

    SELECT @hash_doc = hash_documento, @firmado = firmado
    FROM notaria.VersionDocumento
    WHERE id_version = @id_version;

    IF @hash_doc IS NULL
        THROW 50005, 'La version del documento no existe.', 1;

    IF @firmado = 1
        THROW 50006, 'La version ya fue firmada.', 1;

    IF NOT EXISTS (
        SELECT 1 FROM notaria.Usuario
        WHERE id_usuario = @id_usuario
          AND certificado_vigente = 1
          AND certificado_serial = @certificado_serial
          AND activo = 1
    )
        THROW 50007, 'Certificado electronico invalido o no vigente.', 1;

    BEGIN TRAN;

    INSERT INTO notaria.FirmaElectronica (
        id_version, id_usuario, hash_firmado, certificado_serial
    )
    VALUES (
        @id_version, @id_usuario, @hash_doc, @certificado_serial
    );

    SET @id_firma = SCOPE_IDENTITY();
    SET @id_registro = CAST(@id_firma AS VARCHAR(50));

    UPDATE notaria.VersionDocumento
    SET firmado = 1
    WHERE id_version = @id_version;

    SET @xml = (
        SELECT @id_version AS id_version,
               @id_usuario AS id_usuario,
               @certificado_serial AS certificado
        FOR XML PATH('FirmaElectronica'), TYPE
    );

    EXEC notaria.sp_RegistrarAuditoria
        @id_usuario, 'FirmaElectronica', 'FIRMA', @id_registro, @xml;

    COMMIT TRAN;
END;
GO

CREATE OR ALTER PROCEDURE notaria.sp_CambiarEstadoTramite
    @id_tramite     INT,
    @nuevo_estado   VARCHAR(20),
    @id_usuario     INT
AS
BEGIN
    DECLARE @estado_actual VARCHAR(20);
    DECLARE @xml XML;
    DECLARE @id_registro VARCHAR(50);

    SET XACT_ABORT ON;

    SELECT @estado_actual = estado
    FROM notaria.Tramite
    WHERE id_tramite = @id_tramite;

    IF @estado_actual IS NULL
        THROW 50008, 'El tramite no existe.', 1;

    IF @estado_actual = @nuevo_estado
        RETURN;

    SET @id_registro = CAST(@id_tramite AS VARCHAR(50));

    BEGIN TRAN;

    UPDATE notaria.Tramite
    SET estado = @nuevo_estado,
        fecha_cierre = CASE WHEN @nuevo_estado IN ('CERRADO', 'CANCELADO') THEN SYSUTCDATETIME() ELSE fecha_cierre END
    WHERE id_tramite = @id_tramite;

    SET @xml = (
        SELECT @id_tramite AS id_tramite,
               @estado_actual AS estado_anterior,
               @nuevo_estado AS estado_nuevo
        FOR XML PATH('Tramite'), TYPE
    );

    EXEC notaria.sp_RegistrarAuditoria
        @id_usuario, 'Tramite', 'UPDATE', @id_registro, @xml;

    COMMIT TRAN;
END;
GO

CREATE OR ALTER PROCEDURE notaria.sp_EjecutarRespaldoExpediente
    @id_expediente      INT,
    @ruta_respaldo      NVARCHAR(400),
    @checksum_entrada   VARBINARY(MAX),
    @id_usuario         INT,
    @observaciones      NVARCHAR(300),
    @id_respaldo        INT OUTPUT
AS
BEGIN
    DECLARE @checksum VARBINARY(32);
    DECLARE @xml XML;
    DECLARE @id_registro VARCHAR(50);

    SET XACT_ABORT ON;

    IF NOT EXISTS (SELECT 1 FROM notaria.Expediente WHERE id_expediente = @id_expediente)
        THROW 50009, 'El expediente no existe.', 1;

    SET @checksum = HASHBYTES('SHA2_256', @checksum_entrada);

    BEGIN TRAN;

    INSERT INTO notaria.Respaldo (id_expediente, ruta_respaldo, checksum_archivo, observaciones)
    VALUES (@id_expediente, @ruta_respaldo, @checksum, @observaciones);

    SET @id_respaldo = SCOPE_IDENTITY();
    SET @id_registro = CAST(@id_respaldo AS VARCHAR(50));
    SET @xml = (
        SELECT @id_expediente AS id_expediente,
               @ruta_respaldo AS ruta,
               CONVERT(VARCHAR(64), @checksum, 2) AS checksum_hex
        FOR XML PATH('Respaldo'), TYPE
    );

    EXEC notaria.sp_RegistrarAuditoria
        @id_usuario, 'Respaldo', 'RESPALDO', @id_registro, @xml;

    COMMIT TRAN;
END;
GO

PRINT N'Procedimientos almacenados creados: 6 SPs en esquema notaria.';
GO