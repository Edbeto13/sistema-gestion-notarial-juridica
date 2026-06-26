/*
  =============================================================================
  Sistema de Gestion Notarial y Juridica
  SCRIPT SQL COMPLETO — Entregable unificado
  =============================================================================
  Contenido: creacion de BD, esquema (14 tablas), 6 procedimientos almacenados,
             datos de demostracion y consultas de verificacion.

  Motor:     Microsoft SQL Server (SSMS 22.7.0+)
  BD:        NotariaJuridica
  Esquema:   notaria

  Ejecucion: abrir este archivo en SSMS y ejecutar (F5).
             Requiere permisos para CREATE DATABASE.

  Alternativa por partes: 01_create_database.sql -> 02 -> 03 -> 04
  Datos sinteticos adicionales (opcional): 05_generate_synthetic_data.sql

  Equipo BETAXIS — Universidad de Negocios ISEC — 25 junio 2026
  =============================================================================
*/

/* ========== 01_create_database.sql ========== */

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

/* ========== 02_create_schema.sql ========== */

/*
  Sistema de Gestion Notarial y Juridica
  Script 02: Tablas, claves, indices y restricciones
*/
SET NOCOUNT ON;
GO

USE NotariaJuridica;
GO

/* ------------------------------------------------------------------ */
/* Catalogos y entidades principales                                  */
/* ------------------------------------------------------------------ */

CREATE TABLE notaria.Cliente (
    id_cliente          INT             IDENTITY(1,1) NOT NULL,
    tipo_persona        VARCHAR(15)     NOT NULL,
    nombre_razon        NVARCHAR(200)   NOT NULL,
    identificacion      VARCHAR(30)     NOT NULL,
    correo              VARCHAR(120)    NULL,
    telefono            VARCHAR(30)     NULL,
    direccion           NVARCHAR(250)   NULL,
    fecha_registro      DATETIME2(0)    NOT NULL CONSTRAINT DF_Cliente_fecha_registro DEFAULT SYSUTCDATETIME(),
    activo              BIT             NOT NULL CONSTRAINT DF_Cliente_activo DEFAULT (1),
    CONSTRAINT PK_Cliente PRIMARY KEY (id_cliente),
    CONSTRAINT UQ_Cliente_identificacion UNIQUE (identificacion),
    CONSTRAINT CK_Cliente_tipo_persona CHECK (tipo_persona IN ('FISICA', 'JURIDICA'))
);
GO

CREATE TABLE notaria.TipoTramite (
    id_tipo_tramite     INT             IDENTITY(1,1) NOT NULL,
    codigo              VARCHAR(20)     NOT NULL,
    nombre              NVARCHAR(120)   NOT NULL,
    descripcion         NVARCHAR(400)   NULL,
    activo              BIT             NOT NULL CONSTRAINT DF_TipoTramite_activo DEFAULT (1),
    CONSTRAINT PK_TipoTramite PRIMARY KEY (id_tipo_tramite),
    CONSTRAINT UQ_TipoTramite_codigo UNIQUE (codigo)
);
GO

CREATE TABLE notaria.Expediente (
    id_expediente       INT             IDENTITY(1,1) NOT NULL,
    folio_expediente    VARCHAR(30)     NOT NULL,
    id_cliente          INT             NOT NULL,
    fecha_apertura      DATETIME2(0)    NOT NULL CONSTRAINT DF_Expediente_fecha_apertura DEFAULT SYSUTCDATETIME(),
    estado              VARCHAR(20)     NOT NULL,
    observaciones       NVARCHAR(500)   NULL,
    CONSTRAINT PK_Expediente PRIMARY KEY (id_expediente),
    CONSTRAINT UQ_Expediente_folio UNIQUE (folio_expediente),
    CONSTRAINT FK_Expediente_Cliente FOREIGN KEY (id_cliente)
        REFERENCES notaria.Cliente (id_cliente),
    CONSTRAINT CK_Expediente_estado CHECK (estado IN ('ABIERTO', 'EN_TRAMITE', 'CERRADO', 'ARCHIVADO'))
);
GO

CREATE TABLE notaria.Tramite (
    id_tramite          INT             IDENTITY(1,1) NOT NULL,
    id_expediente       INT             NOT NULL,
    id_tipo_tramite     INT             NOT NULL,
    descripcion         NVARCHAR(300)   NULL,
    estado              VARCHAR(20)     NOT NULL,
    fecha_inicio        DATETIME2(0)    NOT NULL CONSTRAINT DF_Tramite_fecha_inicio DEFAULT SYSUTCDATETIME(),
    fecha_cierre        DATETIME2(0)    NULL,
    CONSTRAINT PK_Tramite PRIMARY KEY (id_tramite),
    CONSTRAINT FK_Tramite_Expediente FOREIGN KEY (id_expediente)
        REFERENCES notaria.Expediente (id_expediente),
    CONSTRAINT FK_Tramite_TipoTramite FOREIGN KEY (id_tipo_tramite)
        REFERENCES notaria.TipoTramite (id_tipo_tramite),
    CONSTRAINT CK_Tramite_estado CHECK (estado IN ('PENDIENTE', 'EN_PROCESO', 'FIRMADO', 'CERRADO', 'CANCELADO'))
);
GO

CREATE TABLE notaria.Documento (
    id_documento        INT             IDENTITY(1,1) NOT NULL,
    id_tramite          INT             NOT NULL,
    tipo_documento      VARCHAR(20)     NOT NULL,
    titulo              NVARCHAR(200)   NOT NULL,
    ruta_archivo        NVARCHAR(400)   NULL,
    fecha_creacion      DATETIME2(0)    NOT NULL CONSTRAINT DF_Documento_fecha_creacion DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Documento PRIMARY KEY (id_documento),
    CONSTRAINT FK_Documento_Tramite FOREIGN KEY (id_tramite)
        REFERENCES notaria.Tramite (id_tramite),
    CONSTRAINT CK_Documento_tipo CHECK (tipo_documento IN ('ACTA', 'CONTRATO', 'ANEXO', 'OTRO'))
);
GO

CREATE TABLE notaria.VersionDocumento (
    id_version          INT             IDENTITY(1,1) NOT NULL,
    id_documento        INT             NOT NULL,
    numero_version      INT             NOT NULL,
    contenido_resumen   NVARCHAR(500)   NULL,
    hash_documento      VARBINARY(32)   NOT NULL,
    firmado             BIT             NOT NULL CONSTRAINT DF_VersionDocumento_firmado DEFAULT (0),
    fecha_version       DATETIME2(0)    NOT NULL CONSTRAINT DF_VersionDocumento_fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_VersionDocumento PRIMARY KEY (id_version),
    CONSTRAINT FK_VersionDocumento_Documento FOREIGN KEY (id_documento)
        REFERENCES notaria.Documento (id_documento),
    CONSTRAINT UQ_VersionDocumento_doc_num UNIQUE (id_documento, numero_version),
    CONSTRAINT CK_VersionDocumento_numero CHECK (numero_version > 0)
);
GO

CREATE TABLE notaria.Acta (
    id_documento        INT             NOT NULL,
    numero_acta         VARCHAR(30)     NOT NULL,
    tipo_acta           NVARCHAR(80)    NOT NULL,
    lugar_celebracion   NVARCHAR(120)   NULL,
    CONSTRAINT PK_Acta PRIMARY KEY (id_documento),
    CONSTRAINT FK_Acta_Documento FOREIGN KEY (id_documento)
        REFERENCES notaria.Documento (id_documento),
    CONSTRAINT UQ_Acta_numero UNIQUE (numero_acta)
);
GO

CREATE TABLE notaria.Contrato (
    id_documento        INT             NOT NULL,
    monto               DECIMAL(18,2)   NULL,
    moneda              CHAR(3)         NOT NULL CONSTRAINT DF_Contrato_moneda DEFAULT ('MXN'),
    vigencia_inicio     DATE            NULL,
    vigencia_fin        DATE            NULL,
    CONSTRAINT PK_Contrato PRIMARY KEY (id_documento),
    CONSTRAINT FK_Contrato_Documento FOREIGN KEY (id_documento)
        REFERENCES notaria.Documento (id_documento)
);
GO

CREATE TABLE notaria.Usuario (
    id_usuario          INT             IDENTITY(1,1) NOT NULL,
    login_usuario       VARCHAR(60)     NOT NULL,
    nombre_completo     NVARCHAR(150)   NOT NULL,
    correo              VARCHAR(120)    NOT NULL,
    certificado_serial  VARCHAR(80)     NULL,
    certificado_vigente BIT             NOT NULL CONSTRAINT DF_Usuario_cert_vigente DEFAULT (0),
    activo              BIT             NOT NULL CONSTRAINT DF_Usuario_activo DEFAULT (1),
    CONSTRAINT PK_Usuario PRIMARY KEY (id_usuario),
    CONSTRAINT UQ_Usuario_login UNIQUE (login_usuario),
    CONSTRAINT UQ_Usuario_correo UNIQUE (correo)
);
GO

CREATE TABLE notaria.Rol (
    id_rol              INT             IDENTITY(1,1) NOT NULL,
    nombre_rol          VARCHAR(40)     NOT NULL,
    descripcion         NVARCHAR(200)   NULL,
    CONSTRAINT PK_Rol PRIMARY KEY (id_rol),
    CONSTRAINT UQ_Rol_nombre UNIQUE (nombre_rol)
);
GO

CREATE TABLE notaria.UsuarioRol (
    id_usuario          INT             NOT NULL,
    id_rol              INT             NOT NULL,
    fecha_asignacion    DATETIME2(0)    NOT NULL CONSTRAINT DF_UsuarioRol_fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_UsuarioRol PRIMARY KEY (id_usuario, id_rol),
    CONSTRAINT FK_UsuarioRol_Usuario FOREIGN KEY (id_usuario)
        REFERENCES notaria.Usuario (id_usuario),
    CONSTRAINT FK_UsuarioRol_Rol FOREIGN KEY (id_rol)
        REFERENCES notaria.Rol (id_rol)
);
GO

CREATE TABLE notaria.FirmaElectronica (
    id_firma            INT             IDENTITY(1,1) NOT NULL,
    id_version          INT             NOT NULL,
    id_usuario          INT             NOT NULL,
    hash_firmado        VARBINARY(32)   NOT NULL,
    certificado_serial  VARCHAR(80)     NOT NULL,
    fecha_firma         DATETIME2(0)    NOT NULL CONSTRAINT DF_Firma_fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_FirmaElectronica PRIMARY KEY (id_firma),
    CONSTRAINT FK_Firma_Version FOREIGN KEY (id_version)
        REFERENCES notaria.VersionDocumento (id_version),
    CONSTRAINT FK_Firma_Usuario FOREIGN KEY (id_usuario)
        REFERENCES notaria.Usuario (id_usuario)
);
GO

CREATE TABLE notaria.Auditoria (
    id_auditoria        BIGINT          IDENTITY(1,1) NOT NULL,
    id_usuario          INT             NULL,
    tabla_afectada      VARCHAR(80)     NOT NULL,
    operacion           VARCHAR(20)     NOT NULL,
    id_registro         VARCHAR(50)     NULL,
    detalle_xml         XML             NOT NULL,
    fecha_evento        DATETIME2(0)    NOT NULL CONSTRAINT DF_Auditoria_fecha DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Auditoria PRIMARY KEY (id_auditoria),
    CONSTRAINT FK_Auditoria_Usuario FOREIGN KEY (id_usuario)
        REFERENCES notaria.Usuario (id_usuario),
    CONSTRAINT CK_Auditoria_operacion CHECK (operacion IN ('INSERT', 'UPDATE', 'DELETE', 'FIRMA', 'RESPALDO', 'CONSULTA'))
);
GO

CREATE TABLE notaria.Respaldo (
    id_respaldo         INT             IDENTITY(1,1) NOT NULL,
    id_expediente       INT             NOT NULL,
    ruta_respaldo       NVARCHAR(400)   NOT NULL,
    checksum_archivo    VARBINARY(32)   NOT NULL,
    fecha_respaldo      DATETIME2(0)    NOT NULL CONSTRAINT DF_Respaldo_fecha DEFAULT SYSUTCDATETIME(),
    observaciones       NVARCHAR(300)   NULL,
    CONSTRAINT PK_Respaldo PRIMARY KEY (id_respaldo),
    CONSTRAINT FK_Respaldo_Expediente FOREIGN KEY (id_expediente)
        REFERENCES notaria.Expediente (id_expediente)
);
GO

/* ------------------------------------------------------------------ */
/* Indices de rendimiento                                             */
/* ------------------------------------------------------------------ */

CREATE INDEX IX_Expediente_Cliente ON notaria.Expediente (id_cliente);
CREATE INDEX IX_Expediente_Estado ON notaria.Expediente (estado);
CREATE INDEX IX_Tramite_Expediente ON notaria.Tramite (id_expediente);
CREATE INDEX IX_Tramite_Estado ON notaria.Tramite (estado);
CREATE INDEX IX_Documento_Tramite ON notaria.Documento (id_tramite);
CREATE INDEX IX_VersionDocumento_Hash ON notaria.VersionDocumento (hash_documento);
CREATE INDEX IX_Auditoria_Fecha ON notaria.Auditoria (fecha_evento DESC);
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE PRIMARY XML INDEX PXML_Auditoria_detalle ON notaria.Auditoria (detalle_xml);
GO

PRINT N'Esquema notaria creado: 14 tablas, restricciones e indices.';
GO

/* ========== 03_stored_procedures.sql ========== */

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

/* ========== 04_seed_data.sql ========== */

/*
  Sistema de Gestion Notarial y Juridica
  Script 04: Datos de ejemplo y demostracion de SPs
*/
SET NOCOUNT ON;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE NotariaJuridica;
GO

/* Catalogo de tipos de tramite */
INSERT INTO notaria.TipoTramite (codigo, nombre, descripcion) VALUES
    ('ESC-001', 'Escritura publica', 'Formalizacion de actos juridicos ante notario'),
    ('POD-001', 'Poder notarial', 'Otorgamiento de representacion legal'),
    ('ACT-001', 'Acta notarial', 'Constancia de hechos o acuerdos');
GO

/* Roles del sistema */
INSERT INTO notaria.Rol (nombre_rol, descripcion) VALUES
    ('NOTARIO', 'Autoriza actos y firmas electronicas'),
    ('SECRETARIO', 'Captura expedientes y documentos'),
    ('ADMINISTRADOR', 'Administra usuarios y respaldos'),
    ('AUDITOR', 'Consulta bitacora de auditoria'),
    ('CLIENTE', 'Consulta limitada de expedientes propios');
GO

/* Usuarios internos */
INSERT INTO notaria.Usuario (login_usuario, nombre_completo, correo, certificado_serial, certificado_vigente) VALUES
    ('notario.garcia', 'Lic. Carlos Garcia Ruiz', 'notario@notaria.demo', 'CERT-NOT-001', 1),
    ('sec.lopez', 'Maria Lopez Hernandez', 'secretaria@notaria.demo', NULL, 0),
    ('admin.sistemas', 'Roberto Diaz Campos', 'admin@notaria.demo', NULL, 0),
    ('auditor.mora', 'Ana Mora Vidal', 'auditor@notaria.demo', NULL, 0);
GO

INSERT INTO notaria.UsuarioRol (id_usuario, id_rol) VALUES
    (1, 1), (2, 2), (3, 3), (4, 4);
GO

/* Clientes */
INSERT INTO notaria.Cliente (tipo_persona, nombre_razon, identificacion, correo, telefono) VALUES
    ('FISICA', 'Juan Perez Martinez', 'CURP-PEMJ850101HDFRRN09', 'juan.perez@email.demo', '5551234567'),
    ('JURIDICA', 'Constructora del Norte SA de CV', 'RFC-CDN900101ABC', 'contacto@cdn.demo', '5559876543');
GO

/* Expedientes via SP */
DECLARE @id_exp1 INT, @id_exp2 INT;

EXEC notaria.sp_AbrirExpediente
    @id_cliente = 1,
    @folio_expediente = 'EXP-2026-0001',
    @id_usuario = 2,
    @observaciones = N'Compraventa de inmueble residencial',
    @id_expediente = @id_exp1 OUTPUT;

EXEC notaria.sp_AbrirExpediente
    @id_cliente = 2,
    @folio_expediente = 'EXP-2026-0002',
    @id_usuario = 2,
    @observaciones = N'Contrato de arrendamiento comercial',
    @id_expediente = @id_exp2 OUTPUT;
GO

/* Tramites */
INSERT INTO notaria.Tramite (id_expediente, id_tipo_tramite, descripcion, estado) VALUES
    (1, 1, N'Escritura de compraventa casa habitacion', 'EN_PROCESO'),
    (1, 3, N'Acta de identificacion de comparecientes', 'PENDIENTE'),
    (2, 1, N'Contrato de arrendamiento local comercial', 'EN_PROCESO');
GO

/* Documentos */
INSERT INTO notaria.Documento (id_tramite, tipo_documento, titulo, ruta_archivo) VALUES
    (1, 'CONTRATO', N'Contrato de compraventa borrador', N'archivos-digitalizados/EXP-2026-0001/contrato-compraventa.pdf.txt'),
    (2, 'ACTA', N'Acta de comparecencia', N'archivos-digitalizados/EXP-2026-0001/acta-comparecencia.pdf.txt'),
    (3, 'CONTRATO', N'Contrato de arrendamiento', N'archivos-digitalizados/EXP-2026-0002/contrato-arrendamiento.pdf.txt');
GO

INSERT INTO notaria.Contrato (id_documento, monto, moneda, vigencia_inicio, vigencia_fin) VALUES
    (1, 2500000.00, 'MXN', '2026-03-01', NULL),
    (3, 45000.00, 'MXN', '2026-04-01', '2027-03-31');
GO

INSERT INTO notaria.Acta (id_documento, numero_acta, tipo_acta, lugar_celebracion) VALUES
    (2, 'ACTA-2026-0042', 'Comparecencia', 'Notaria 15, CDMX');
GO

/* Versiones de documento via SP */
DECLARE @id_ver1 INT, @id_ver2 INT, @id_firma_v1 INT, @id_firma_v2 INT;
DECLARE @contenido1 VARBINARY(MAX) = CONVERT(VARBINARY(MAX), N'Borrador inicial contrato compraventa');
DECLARE @contenido2 VARBINARY(MAX) = CONVERT(VARBINARY(MAX), N'Version revisada contrato compraventa');

EXEC notaria.sp_RegistrarVersionDocumento
    @id_documento = 1,
    @contenido_resumen = N'Borrador v1 con datos de las partes',
    @contenido_hash = @contenido1,
    @id_usuario = 2,
    @id_version = @id_ver1 OUTPUT;

EXEC notaria.sp_AplicarFirmaElectronica
    @id_version = @id_ver1,
    @id_usuario = 1,
    @certificado_serial = 'CERT-NOT-001',
    @id_firma = @id_firma_v1 OUTPUT;

EXEC notaria.sp_RegistrarVersionDocumento
    @id_documento = 1,
    @contenido_resumen = N'Version v2 con clausulas corregidas',
    @contenido_hash = @contenido2,
    @id_usuario = 2,
    @id_version = @id_ver2 OUTPUT;

EXEC notaria.sp_AplicarFirmaElectronica
    @id_version = @id_ver2,
    @id_usuario = 1,
    @certificado_serial = 'CERT-NOT-001',
    @id_firma = @id_firma_v2 OUTPUT;
GO

/* Cambio de estado y respaldo */
EXEC notaria.sp_CambiarEstadoTramite
    @id_tramite = 1,
    @nuevo_estado = 'FIRMADO',
    @id_usuario = 1;
GO

DECLARE @id_respaldo INT;
DECLARE @archivo VARBINARY(MAX) = CONVERT(VARBINARY(MAX), N'Paquete respaldo expediente EXP-2026-0001');

EXEC notaria.sp_EjecutarRespaldoExpediente
    @id_expediente = 1,
    @ruta_respaldo = N'\\backup\\2026\\06\\EXP-2026-0001.zip',
    @checksum_entrada = @archivo,
    @id_usuario = 3,
    @observaciones = N'Respaldo diario automatico',
    @id_respaldo = @id_respaldo OUTPUT;
GO

/* Consultas de verificacion */
PRINT N'--- Resumen de datos cargados ---';

SELECT 'Clientes' AS entidad, COUNT(*) AS total FROM notaria.Cliente
UNION ALL SELECT 'Expedientes', COUNT(*) FROM notaria.Expediente
UNION ALL SELECT 'Tramites', COUNT(*) FROM notaria.Tramite
UNION ALL SELECT 'Documentos', COUNT(*) FROM notaria.Documento
UNION ALL SELECT 'Versiones', COUNT(*) FROM notaria.VersionDocumento
UNION ALL SELECT 'Firmas', COUNT(*) FROM notaria.FirmaElectronica
UNION ALL SELECT 'Auditorias', COUNT(*) FROM notaria.Auditoria
UNION ALL SELECT 'Respaldos', COUNT(*) FROM notaria.Respaldo;
GO

PRINT N'Datos de ejemplo cargados correctamente.';
GO
