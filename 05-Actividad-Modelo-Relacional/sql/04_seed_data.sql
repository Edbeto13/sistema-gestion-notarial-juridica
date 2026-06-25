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
    (1, 'CONTRATO', N'Contrato de compraventa borrador', N'\\archivo\\exp2026\\doc001.pdf'),
    (2, 'ACTA', N'Acta de comparecencia', N'\\archivo\\exp2026\\doc002.pdf'),
    (3, 'CONTRATO', N'Contrato de arrendamiento', N'\\archivo\\exp2026\\doc003.pdf');
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