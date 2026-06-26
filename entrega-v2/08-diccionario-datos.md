# 8. Diccionario de Datos

Esquema: `notaria` · Base de datos: `NotariaJuridica` · Motor: SQL Server.

---

## notaria.Cliente

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_cliente | INT | 4 | Sí | — | No | Identificador interno autoincremental |
| tipo_persona | VARCHAR | 15 | — | — | No | FISICA o JURIDICA |
| nombre_razon | NVARCHAR | 200 | — | — | No | Nombre completo o razón social |
| identificacion | VARCHAR | 30 | — | — | No | CURP, RFC u otro identificador único |
| correo | VARCHAR | 120 | — | — | Sí | Correo electrónico de contacto |
| telefono | VARCHAR | 30 | — | — | Sí | Teléfono de contacto |
| direccion | NVARCHAR | 250 | — | — | Sí | Domicilio fiscal o de notificación |
| fecha_registro | DATETIME2 | 0 | — | — | No | Fecha UTC de alta en el sistema |
| activo | BIT | 1 | — | — | No | 1 = cliente vigente; 0 = baja lógica |

---

## notaria.TipoTramite

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_tipo_tramite | INT | 4 | Sí | — | No | Identificador del catálogo |
| codigo | VARCHAR | 20 | — | — | No | Código único (ej. ESC-001) |
| nombre | NVARCHAR | 120 | — | — | No | Nombre descriptivo del trámite |
| descripcion | NVARCHAR | 400 | — | — | Sí | Detalle del tipo de acto notarial |
| activo | BIT | 1 | — | — | No | Indica si el tipo está habilitado |

---

## notaria.Expediente

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_expediente | INT | 4 | Sí | — | No | Identificador interno |
| folio_expediente | VARCHAR | 30 | — | — | No | Folio único visible (ej. EXP-2026-0001) |
| id_cliente | INT | 4 | — | Cliente.id_cliente | No | Cliente titular del expediente |
| fecha_apertura | DATETIME2 | 0 | — | — | No | Fecha de apertura del expediente |
| estado | VARCHAR | 20 | — | — | No | ABIERTO, EN_TRAMITE, CERRADO, ARCHIVADO |
| observaciones | NVARCHAR | 500 | — | — | Sí | Notas administrativas |

---

## notaria.Tramite

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_tramite | INT | 4 | Sí | — | No | Identificador del trámite |
| id_expediente | INT | 4 | — | Expediente.id_expediente | No | Expediente contenedor |
| id_tipo_tramite | INT | 4 | — | TipoTramite.id_tipo_tramite | No | Clasificación del acto |
| descripcion | NVARCHAR | 300 | — | — | Sí | Descripción operativa |
| estado | VARCHAR | 20 | — | — | No | PENDIENTE, EN_PROCESO, FIRMADO, CERRADO, CANCELADO |
| fecha_inicio | DATETIME2 | 0 | — | — | No | Inicio del trámite |
| fecha_cierre | DATETIME2 | 0 | — | — | Sí | Cierre cuando aplica |

---

## notaria.Documento

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_documento | INT | 4 | Sí | — | No | Identificador del documento lógico |
| id_tramite | INT | 4 | — | Tramite.id_tramite | No | Trámite que generó el documento |
| tipo_documento | VARCHAR | 20 | — | — | No | ACTA, CONTRATO, ANEXO, OTRO |
| titulo | NVARCHAR | 200 | — | — | No | Título o nombre del documento |
| ruta_archivo | NVARCHAR | 400 | — | — | Sí | Ruta al archivo digitalizado |
| fecha_creacion | DATETIME2 | 0 | — | — | No | Fecha de registro en el sistema |

---

## notaria.VersionDocumento

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_version | INT | 4 | Sí | — | No | Identificador de la versión |
| id_documento | INT | 4 | — | Documento.id_documento | No | Documento versionado |
| numero_version | INT | 4 | — | — | No | Número secuencial (> 0) |
| contenido_resumen | NVARCHAR | 500 | — | — | Sí | Resumen textual del contenido |
| hash_documento | VARBINARY | 32 | — | — | No | Hash SHA-256 del contenido |
| firmado | BIT | 1 | — | — | No | 1 = versión firmada electrónicamente |
| fecha_version | DATETIME2 | 0 | — | — | No | Fecha de creación de la versión |

---

## notaria.Acta

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_documento | INT | 4 | Sí | Documento.id_documento | No | Especialización ISA del documento |
| numero_acta | VARCHAR | 30 | — | — | No | Número de acta en protocolo |
| tipo_acta | NVARCHAR | 80 | — | — | No | Tipo (comparecencia, constancia, etc.) |
| lugar_celebracion | NVARCHAR | 120 | — | — | Sí | Lugar donde se celebró el acto |

---

## notaria.Contrato

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_documento | INT | 4 | Sí | Documento.id_documento | No | Especialización ISA del documento |
| monto | DECIMAL | 18,2 | — | — | Sí | Monto económico del contrato |
| moneda | CHAR | 3 | — | — | No | Código ISO de moneda (default MXN) |
| vigencia_inicio | DATE | — | — | — | Sí | Inicio de vigencia |
| vigencia_fin | DATE | — | — | — | Sí | Fin de vigencia |

---

## notaria.Usuario

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_usuario | INT | 4 | Sí | — | No | Identificador del operador interno |
| login_usuario | VARCHAR | 60 | — | — | No | Nombre de acceso único |
| nombre_completo | NVARCHAR | 150 | — | — | No | Nombre para mostrar |
| correo | VARCHAR | 120 | — | — | No | Correo institucional único |
| certificado_serial | VARCHAR | 80 | — | — | Sí | Serial del certificado de firma |
| certificado_vigente | BIT | 1 | — | — | No | 1 = certificado válido para firmar |
| activo | BIT | 1 | — | — | No | 1 = usuario habilitado |

---

## notaria.Rol

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_rol | INT | 4 | Sí | — | No | Identificador del rol |
| nombre_rol | VARCHAR | 40 | — | — | No | NOTARIO, SECRETARIO, etc. |
| descripcion | NVARCHAR | 200 | — | — | Sí | Descripción de permisos |

---

## notaria.UsuarioRol

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_usuario | INT | 4 | Sí | Usuario.id_usuario | No | Usuario asignado |
| id_rol | INT | 4 | Sí | Rol.id_rol | No | Rol asignado |
| fecha_asignacion | DATETIME2 | 0 | — | — | No | Fecha de la asignación |

---

## notaria.FirmaElectronica

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_firma | INT | 4 | Sí | — | No | Identificador de la firma |
| id_version | INT | 4 | — | VersionDocumento.id_version | No | Versión firmada |
| id_usuario | INT | 4 | — | Usuario.id_usuario | No | Notario que firma |
| hash_firmado | VARBINARY | 32 | — | — | No | Hash del documento al momento de firmar |
| certificado_serial | VARCHAR | 80 | — | — | No | Serial del certificado utilizado |
| fecha_firma | DATETIME2 | 0 | — | — | No | Marca temporal de la firma |

---

## notaria.Auditoria

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_auditoria | BIGINT | 8 | Sí | — | No | Identificador del evento |
| id_usuario | INT | 4 | — | Usuario.id_usuario | Sí | Usuario que ejecutó la operación |
| tabla_afectada | VARCHAR | 80 | — | — | No | Tabla o entidad afectada |
| operacion | VARCHAR | 20 | — | — | No | INSERT, UPDATE, DELETE, FIRMA, RESPALDO, CONSULTA |
| id_registro | VARCHAR | 50 | — | — | Sí | Identificador del registro afectado |
| detalle_xml | XML | — | — | — | No | Detalle estructurado del evento |
| fecha_evento | DATETIME2 | 0 | — | — | No | Fecha UTC del evento |

---

## notaria.Respaldo

| Campo | Tipo | Longitud | PK | FK | Nulo | Descripción |
|-------|------|---------:|:--:|:--:|:----:|-------------|
| id_respaldo | INT | 4 | Sí | — | No | Identificador del respaldo |
| id_expediente | INT | 4 | — | Expediente.id_expediente | No | Expediente respaldado |
| ruta_respaldo | NVARCHAR | 400 | — | — | No | Ubicación del archivo de respaldo |
| checksum_archivo | VARBINARY | 32 | — | — | No | Hash SHA-256 del paquete |
| fecha_respaldo | DATETIME2 | 0 | — | — | No | Fecha de generación |
| observaciones | NVARCHAR | 300 | — | — | Sí | Notas del respaldo |

---

**Total:** 14 tablas · 89 columnas documentadas.