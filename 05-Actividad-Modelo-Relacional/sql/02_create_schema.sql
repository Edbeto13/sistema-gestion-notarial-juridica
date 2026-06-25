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