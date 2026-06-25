/*
  Sistema de Gestion Notarial y Juridica
  Script 05: Generacion de datos sinteticos

  Requisitos: ejecutar despues de 01-04 (esquema, SPs y datos base).
  Usa los procedimientos almacenados para mantener auditoria y reglas de negocio.

  Parametros (editar al inicio del bloque principal):
    @num_clientes_nuevos     Clientes sinteticos a insertar
    @expedientes_min/max     Rango de expedientes por cliente
    @tramites_min/max        Rango de tramites por expediente
    @docs_min/max            Rango de documentos por tramite
    @versiones_max           Versiones por documento (cada una se firma antes de la siguiente)
    @pct_firma               Probabilidad de firmar la ultima version (0.0 - 1.0)
    @pct_respaldo            Probabilidad de respaldar un expediente cerrado/en tramite
*/
SET NOCOUNT ON;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

USE NotariaJuridica;
GO

/* ------------------------------------------------------------------ */
/* Catalogos auxiliares en memoria para nombres y descripciones       */
/* ------------------------------------------------------------------ */

DECLARE @nombres TABLE (id INT IDENTITY(1,1), valor NVARCHAR(80) NOT NULL);
INSERT INTO @nombres (valor) VALUES
    (N'Carlos'), (N'Maria'), (N'Jose'), (N'Ana'), (N'Luis'), (N'Patricia'),
    (N'Roberto'), (N'Laura'), (N'Fernando'), (N'Gabriela'), (N'Ricardo'),
    (N'Silvia'), (N'Alberto'), (N'Claudia'), (N'Jorge'), (N'Beatriz'),
    (N'Manuel'), (N'Rosa'), (N'Arturo'), (N'Veronica');

DECLARE @apellidos TABLE (id INT IDENTITY(1,1), valor NVARCHAR(80) NOT NULL);
INSERT INTO @apellidos (valor) VALUES
    (N'Garcia'), (N'Rodriguez'), (N'Martinez'), (N'Hernandez'), (N'Lopez'),
    (N'Gonzalez'), (N'Perez'), (N'Sanchez'), (N'Ramirez'), (N'Torres'),
    (N'Flores'), (N'Rivera'), (N'Gomez'), (N'Diaz'), (N'Cruz'), (N'Morales');

DECLARE @empresas TABLE (id INT IDENTITY(1,1), valor NVARCHAR(120) NOT NULL);
INSERT INTO @empresas (valor) VALUES
    (N'Inmobiliaria Horizonte SA de CV'),
    (N'Servicios Legales del Centro SC'),
    (N'Constructora Metropolitana SA'),
    (N'Comercializadora Azteca SA de CV'),
    (N'Desarrollos Urbanos del Pacifico SA'),
    (N'Grupo Financiero del Norte SC'),
    (N'Tecnologia y Sistemas Integrales SA'),
    (N'Agroexportadora La Cienega SA de CV');

DECLARE @colonias TABLE (id INT IDENTITY(1,1), valor NVARCHAR(80) NOT NULL);
INSERT INTO @colonias (valor) VALUES
    (N'Centro'), (N'Del Valle'), (N'Reforma'), (N'Narvarte'),
    (N'Polanco'), (N'Coyoacan'), (N'Roma Norte'), (N'Insurgentes Sur');

DECLARE @obs_exp TABLE (id INT IDENTITY(1,1), valor NVARCHAR(200) NOT NULL);
INSERT INTO @obs_exp (valor) VALUES
    (N'Compraventa de inmueble residencial'),
    (N'Constitucion de sociedad mercantil'),
    (N'Poder general para pleitos y cobranzas'),
    (N'Contrato de arrendamiento comercial'),
    (N'Protocolizacion de acta de asamblea'),
    (N'Fideicomiso de garantia'),
    (N'Cancelacion de hipoteca'),
    (N'Donacion de bien inmueble');

/* ------------------------------------------------------------------ */
/* Parametros de volumen                                              */
/* ------------------------------------------------------------------ */

DECLARE @num_clientes_nuevos   INT           = 40;
DECLARE @expedientes_min       INT           = 1;
DECLARE @expedientes_max       INT           = 3;
DECLARE @tramites_min          INT           = 1;
DECLARE @tramites_max          INT           = 2;
DECLARE @docs_min              INT           = 1;
DECLARE @docs_max              INT           = 3;
DECLARE @versiones_max         INT           = 3;
DECLARE @pct_firma             DECIMAL(5,4)  = 0.85;
DECLARE @pct_respaldo          DECIMAL(5,4)  = 0.60;
DECLARE @folio_base            INT           = 10000;
DECLARE @acta_base             INT           = 10000;
DECLARE @anio                  CHAR(4)       = '2026';

DECLARE @id_notario            INT           = 1;
DECLARE @id_secretario         INT           = 2;
DECLARE @id_admin              INT           = 3;
DECLARE @cert_notario          VARCHAR(80)   = 'CERT-NOT-001';

DECLARE @cnt_clientes          INT           = 0;
DECLARE @cnt_expedientes       INT           = 0;
DECLARE @cnt_tramites          INT           = 0;
DECLARE @cnt_documentos        INT           = 0;
DECLARE @cnt_versiones         INT           = 0;
DECLARE @cnt_firmas            INT           = 0;
DECLARE @cnt_respaldos         INT           = 0;

DECLARE @i                     INT;
DECLARE @j                     INT;
DECLARE @k                     INT;
DECLARE @d                     INT;
DECLARE @v                     INT;

DECLARE @tipo_persona          VARCHAR(15);
DECLARE @nombre                NVARCHAR(200);
DECLARE @identificacion        VARCHAR(30);
DECLARE @correo                VARCHAR(120);
DECLARE @telefono              VARCHAR(30);
DECLARE @direccion             NVARCHAR(250);
DECLARE @id_cliente            INT;
DECLARE @num_exp               INT;
DECLARE @folio                 VARCHAR(30);
DECLARE @id_expediente         INT;
DECLARE @obs                   NVARCHAR(500);
DECLARE @num_tram              INT;
DECLARE @id_tipo_tramite       INT;
DECLARE @estado_tram           VARCHAR(20);
DECLARE @desc_tram             NVARCHAR(300);
DECLARE @id_tramite            INT;
DECLARE @num_doc               INT;
DECLARE @tipo_doc              VARCHAR(20);
DECLARE @titulo_doc            NVARCHAR(200);
DECLARE @ruta_doc              NVARCHAR(400);
DECLARE @id_documento          INT;
DECLARE @num_ver               INT;
DECLARE @id_version            INT;
DECLARE @id_firma              INT;
DECLARE @contenido             VARBINARY(MAX);
DECLARE @resumen               NVARCHAR(500);
DECLARE @monto                 DECIMAL(18,2);
DECLARE @num_acta              VARCHAR(30);
DECLARE @id_respaldo           INT;
DECLARE @estado_exp            VARCHAR(20);
DECLARE @firmar_ultima         BIT;
DECLARE @payload               NVARCHAR(500);
DECLARE @payload_respaldo      NVARCHAR(200);
DECLARE @ruta_backup           NVARCHAR(400);

DECLARE @max_nombre            INT = (SELECT COUNT(*) FROM @nombres);
DECLARE @max_apellido          INT = (SELECT COUNT(*) FROM @apellidos);
DECLARE @max_empresa           INT = (SELECT COUNT(*) FROM @empresas);
DECLARE @max_colonia           INT = (SELECT COUNT(*) FROM @colonias);
DECLARE @max_obs               INT = (SELECT COUNT(*) FROM @obs_exp);
DECLARE @max_tipo_tramite      INT = (SELECT COUNT(*) FROM notaria.TipoTramite);

PRINT N'=== Inicio generacion de datos sinteticos ===';
PRINT N'Clientes a generar: ' + CAST(@num_clientes_nuevos AS NVARCHAR(10));

/* ------------------------------------------------------------------ */
/* 1. Clientes sinteticos                                             */
/* ------------------------------------------------------------------ */

SET @i = 1;
WHILE @i <= @num_clientes_nuevos
BEGIN
    IF (ABS(CHECKSUM(NEWID())) % 100) < 25
    BEGIN
        SET @tipo_persona = 'JURIDICA';
        SET @nombre = (SELECT TOP 1 valor FROM @empresas ORDER BY NEWID());
        SET @identificacion = 'RFC-SYN' + RIGHT('00000000' + CAST(@i + @folio_base AS VARCHAR(8)), 8);
    END
    ELSE
    BEGIN
        SET @tipo_persona = 'FISICA';
        SET @nombre =
            (SELECT TOP 1 valor FROM @nombres ORDER BY NEWID()) + N' ' +
            (SELECT TOP 1 valor FROM @apellidos ORDER BY NEWID()) + N' ' +
            (SELECT TOP 1 valor FROM @apellidos ORDER BY NEWID());
        SET @identificacion = 'CURP-SYN' + RIGHT('00000000' + CAST(@i + @folio_base AS VARCHAR(8)), 8);
    END;

    SET @correo = 'cliente.syn' + CAST(@i + @folio_base AS VARCHAR(10)) + '@notaria.demo';
    SET @telefono = '555' + RIGHT('0000000' + CAST(ABS(CHECKSUM(NEWID())) % 10000000 AS VARCHAR(7)), 7);
    SET @direccion = N'Calle ' + CAST((ABS(CHECKSUM(NEWID())) % 900) + 100 AS NVARCHAR(10)) + N', Col. ' +
        (SELECT TOP 1 valor FROM @colonias ORDER BY NEWID()) + N', CDMX';

    INSERT INTO notaria.Cliente (tipo_persona, nombre_razon, identificacion, correo, telefono, direccion, activo)
    VALUES (@tipo_persona, @nombre, @identificacion, @correo, @telefono, @direccion, 1);

    SET @id_cliente = SCOPE_IDENTITY();
    SET @cnt_clientes = @cnt_clientes + 1;

    /* -------------------------------------------------------------- */
    /* 2. Expedientes por cliente (via SP)                            */
    /* -------------------------------------------------------------- */

    SET @num_exp = @expedientes_min + (ABS(CHECKSUM(NEWID())) % (@expedientes_max - @expedientes_min + 1));
    SET @j = 1;

    WHILE @j <= @num_exp
    BEGIN
        SET @folio = 'EXP-' + @anio + '-' + RIGHT('00000' + CAST(@folio_base + @cnt_expedientes + 1 AS VARCHAR(10)), 5);
        SET @obs = (SELECT TOP 1 valor FROM @obs_exp ORDER BY NEWID());

        BEGIN TRY
            EXEC notaria.sp_AbrirExpediente
                @id_cliente       = @id_cliente,
                @folio_expediente = @folio,
                @id_usuario       = @id_secretario,
                @observaciones    = @obs,
                @id_expediente    = @id_expediente OUTPUT;

            SET @cnt_expedientes = @cnt_expedientes + 1;

            /* ------------------------------------------------------ */
            /* 3. Tramites por expediente                             */
            /* ------------------------------------------------------ */

            SET @num_tram = @tramites_min + (ABS(CHECKSUM(NEWID())) % (@tramites_max - @tramites_min + 1));
            SET @k = 1;

            WHILE @k <= @num_tram
            BEGIN
                SET @id_tipo_tramite = (ABS(CHECKSUM(NEWID())) % @max_tipo_tramite) + 1;

                SET @estado_tram = CASE ABS(CHECKSUM(NEWID())) % 5
                    WHEN 0 THEN 'PENDIENTE'
                    WHEN 1 THEN 'EN_PROCESO'
                    WHEN 2 THEN 'FIRMADO'
                    WHEN 3 THEN 'CERRADO'
                    ELSE 'CANCELADO'
                END;

                SET @desc_tram = CASE @id_tipo_tramite
                    WHEN 1 THEN N'Tramite de escritura publica - expediente ' + @folio
                    WHEN 2 THEN N'Tramite de poder notarial - expediente ' + @folio
                    ELSE N'Tramite de acta notarial - expediente ' + @folio
                END;

                INSERT INTO notaria.Tramite (id_expediente, id_tipo_tramite, descripcion, estado)
                VALUES (@id_expediente, @id_tipo_tramite, @desc_tram, @estado_tram);

                SET @id_tramite = SCOPE_IDENTITY();
                SET @cnt_tramites = @cnt_tramites + 1;

                /* -------------------------------------------------- */
                /* 4. Documentos por tramite                          */
                /* -------------------------------------------------- */

                SET @num_doc = @docs_min + (ABS(CHECKSUM(NEWID())) % (@docs_max - @docs_min + 1));
                SET @d = 1;

                WHILE @d <= @num_doc
                BEGIN
                    SET @tipo_doc = CASE ABS(CHECKSUM(NEWID())) % 4
                        WHEN 0 THEN 'ACTA'
                        WHEN 1 THEN 'CONTRATO'
                        WHEN 2 THEN 'ANEXO'
                        ELSE 'OTRO'
                    END;

                    SET @titulo_doc = @tipo_doc + N' - ' + @folio + N' - doc ' + CAST(@d AS NVARCHAR(5));
                    SET @ruta_doc = N'\\archivo\\' + @anio + N'\\' + @folio + N'\\doc_' +
                        CAST(@cnt_documentos + @d AS NVARCHAR(10)) + N'.pdf';

                    INSERT INTO notaria.Documento (id_tramite, tipo_documento, titulo, ruta_archivo)
                    VALUES (@id_tramite, @tipo_doc, @titulo_doc, @ruta_doc);

                    SET @id_documento = SCOPE_IDENTITY();
                    SET @cnt_documentos = @cnt_documentos + 1;

                    IF @tipo_doc = 'ACTA'
                    BEGIN
                        SET @acta_base = @acta_base + 1;
                        SET @num_acta = 'ACTA-' + @anio + '-' + RIGHT('00000' + CAST(@acta_base AS VARCHAR(10)), 5);
                        INSERT INTO notaria.Acta (id_documento, numero_acta, tipo_acta, lugar_celebracion)
                        VALUES (
                            @id_documento,
                            @num_acta,
                            CASE ABS(CHECKSUM(NEWID())) % 3
                                WHEN 0 THEN N'Comparecencia'
                                WHEN 1 THEN N'Identificacion'
                                ELSE N'Asamblea'
                            END,
                            N'Notaria 15, CDMX'
                        );
                    END;

                    IF @tipo_doc = 'CONTRATO'
                    BEGIN
                        SET @monto = CAST((ABS(CHECKSUM(NEWID())) % 5000000) + 10000 AS DECIMAL(18,2));
                        INSERT INTO notaria.Contrato (id_documento, monto, moneda, vigencia_inicio, vigencia_fin)
                        VALUES (
                            @id_documento,
                            @monto,
                            'MXN',
                            DATEADD(DAY, -(ABS(CHECKSUM(NEWID())) % 180), CAST(GETDATE() AS DATE)),
                            CASE WHEN ABS(CHECKSUM(NEWID())) % 2 = 0
                                THEN DATEADD(YEAR, 1, CAST(GETDATE() AS DATE))
                                ELSE NULL
                            END
                        );
                    END;

                    /* ---------------------------------------------- */
                    /* 5. Versiones y firmas                          */
                    /* ---------------------------------------------- */

                    SET @num_ver = 1 + (ABS(CHECKSUM(NEWID())) % @versiones_max);
                    SET @firmar_ultima = CASE
                        WHEN (ABS(CHECKSUM(NEWID())) % 10000) / 10000.0 <= @pct_firma THEN 1
                        ELSE 0
                    END;

                    SET @v = 1;
                    WHILE @v <= @num_ver
                    BEGIN
                        SET @payload = N'Contenido sintetico doc ' + CAST(@id_documento AS NVARCHAR(10)) +
                            N' version ' + CAST(@v AS NVARCHAR(5)) + N' folio ' + @folio;
                        SET @contenido = CAST(@payload AS VARBINARY(MAX));
                        SET @resumen = N'Version ' + CAST(@v AS NVARCHAR(5)) + N' de ' + @titulo_doc;

                        BEGIN TRY
                            EXEC notaria.sp_RegistrarVersionDocumento
                                @id_documento      = @id_documento,
                                @contenido_resumen = @resumen,
                                @contenido_hash    = @contenido,
                                @id_usuario        = @id_secretario,
                                @id_version        = @id_version OUTPUT;

                            SET @cnt_versiones = @cnt_versiones + 1;

                            IF @v < @num_ver OR @firmar_ultima = 1
                            BEGIN
                                EXEC notaria.sp_AplicarFirmaElectronica
                                    @id_version         = @id_version,
                                    @id_usuario         = @id_notario,
                                    @certificado_serial = @cert_notario,
                                    @id_firma           = @id_firma OUTPUT;

                                SET @cnt_firmas = @cnt_firmas + 1;
                            END;
                        END TRY
                        BEGIN CATCH
                            SET @v = @v;
                        END CATCH;

                        SET @v = @v + 1;
                    END;

                    SET @d = @d + 1;
                END;

                /* Actualizar estado tramite si tiene version firmada */
                IF EXISTS (
                    SELECT 1
                    FROM notaria.Documento d
                    JOIN notaria.VersionDocumento v ON v.id_documento = d.id_documento
                    WHERE d.id_tramite = @id_tramite AND v.firmado = 1
                ) AND @estado_tram IN ('PENDIENTE', 'EN_PROCESO')
                BEGIN
                    EXEC notaria.sp_CambiarEstadoTramite
                        @id_tramite   = @id_tramite,
                        @nuevo_estado = 'FIRMADO',
                        @id_usuario   = @id_notario;
                END;

                SET @k = @k + 1;
            END;

            /* ------------------------------------------------------ */
            /* 6. Respaldo opcional del expediente                    */
            /* ------------------------------------------------------ */

            IF (ABS(CHECKSUM(NEWID())) % 10000) / 10000.0 <= @pct_respaldo
            BEGIN
                SET @payload_respaldo = N'Respaldo sintetico ' + @folio;
                SET @contenido = CAST(@payload_respaldo AS VARBINARY(MAX));
                SET @ruta_backup = N'\\backup\\' + RTRIM(@anio) + N'\\06\\' + @folio + N'.zip';
                BEGIN TRY
                    EXEC notaria.sp_EjecutarRespaldoExpediente
                        @id_expediente    = @id_expediente,
                        @ruta_respaldo    = @ruta_backup,
                        @checksum_entrada = @contenido,
                        @id_usuario       = @id_admin,
                        @observaciones    = N'Respaldo sintetico automatico',
                        @id_respaldo      = @id_respaldo OUTPUT;
                    SET @cnt_respaldos = @cnt_respaldos + 1;
                END TRY
                BEGIN CATCH
                    SET @cnt_respaldos = @cnt_respaldos;
                END CATCH;
            END;

            /* Actualizar estado del expediente */
            SET @estado_exp = CASE ABS(CHECKSUM(NEWID())) % 4
                WHEN 0 THEN 'ABIERTO'
                WHEN 1 THEN 'EN_TRAMITE'
                WHEN 2 THEN 'CERRADO'
                ELSE 'ARCHIVADO'
            END;

            UPDATE notaria.Expediente
            SET estado = @estado_exp
            WHERE id_expediente = @id_expediente;

        END TRY
        BEGIN CATCH
            PRINT N'Advertencia expediente ' + ISNULL(@folio, N'?') + N': ' + ERROR_MESSAGE();
        END CATCH;

        SET @j = @j + 1;
    END;

    SET @i = @i + 1;
END;

/* ------------------------------------------------------------------ */
/* Resumen                                                            */
/* ------------------------------------------------------------------ */

PRINT N'';
PRINT N'=== Datos sinteticos generados en esta ejecucion ===';
PRINT N'Clientes nuevos:    ' + CAST(@cnt_clientes AS NVARCHAR(10));
PRINT N'Expedientes nuevos:  ' + CAST(@cnt_expedientes AS NVARCHAR(10));
PRINT N'Tramites nuevos:     ' + CAST(@cnt_tramites AS NVARCHAR(10));
PRINT N'Documentos nuevos:   ' + CAST(@cnt_documentos AS NVARCHAR(10));
PRINT N'Versiones nuevas:     ' + CAST(@cnt_versiones AS NVARCHAR(10));
PRINT N'Firmas nuevas:        ' + CAST(@cnt_firmas AS NVARCHAR(10));
PRINT N'Respaldos nuevos:     ' + CAST(@cnt_respaldos AS NVARCHAR(10));
PRINT N'';

PRINT N'--- Totales en base de datos ---';

SELECT 'Clientes' AS entidad, COUNT(*) AS total FROM notaria.Cliente
UNION ALL SELECT 'Expedientes', COUNT(*) FROM notaria.Expediente
UNION ALL SELECT 'Tramites', COUNT(*) FROM notaria.Tramite
UNION ALL SELECT 'Documentos', COUNT(*) FROM notaria.Documento
UNION ALL SELECT 'Versiones', COUNT(*) FROM notaria.VersionDocumento
UNION ALL SELECT 'Firmas', COUNT(*) FROM notaria.FirmaElectronica
UNION ALL SELECT 'Auditorias', COUNT(*) FROM notaria.Auditoria
UNION ALL SELECT 'Respaldos', COUNT(*) FROM notaria.Respaldo
ORDER BY entidad;
GO

PRINT N'Generacion de datos sinteticos completada.';
GO