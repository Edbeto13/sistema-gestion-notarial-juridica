# Entregable — Actividad 3

## Entidades, descripción, atributos y claves (L43–L46)

| Entidad | Descripción | Atributos principales | Claves |
|---------|-------------|----------------------|--------|
| **Cliente** | Persona física o moral solicitante | tipo_persona, nombre_razon, identificacion, correo, telefono, direccion, fecha_registro, activo | PK: id_cliente; UQ: identificacion |
| **Expediente** | Carpeta que agrupa trámites | folio_expediente, id_cliente, fecha_apertura, estado, observaciones | PK: id_expediente; UQ: folio_expediente |
| **TipoTramite** | Catálogo de tipos | codigo, nombre, descripcion, activo | PK: id_tipo_tramite; UQ: codigo |
| **Tramite** | Procedimiento dentro del expediente | id_expediente, id_tipo_tramite, descripcion, estado, fecha_inicio, fecha_cierre | PK: id_tramite |
| **Documento** | Archivo lógico del trámite | id_tramite, tipo_documento, titulo, ruta_archivo, fecha_creacion | PK: id_documento |
| **VersionDocumento** | Revisión inmutable | id_documento, numero_version, contenido_resumen, hash_documento, firmado, fecha_version | PK: id_version; UQ: (id_documento, numero_version) |
| **Acta** | Especialización de documento notarial | id_documento, numero_acta, tipo_acta, lugar_celebracion | PK/FK: id_documento; UQ: numero_acta |
| **Contrato** | Especialización con datos económicos | id_documento, monto, moneda, vigencia_inicio, vigencia_fin | PK/FK: id_documento |
| **Usuario** | Operador interno | login_usuario, nombre_completo, correo, certificado_serial, certificado_vigente, activo | PK: id_usuario; UQ: login, correo |
| **Rol** | Perfil de permisos | nombre_rol, descripcion | PK: id_rol; UQ: nombre_rol |
| **UsuarioRol** | Asignación N:M | id_usuario, id_rol, fecha_asignacion | PK: (id_usuario, id_rol) |
| **FirmaElectronica** | Evidencia criptográfica | id_version, id_usuario, hash_firmado, certificado_serial, fecha_firma | PK: id_firma |
| **Auditoria** | Bitácora de operaciones | id_usuario, tabla_afectada, operacion, id_registro, detalle_xml, fecha_evento | PK: id_auditoria |
| **Respaldo** | Copia de seguridad | id_expediente, ruta_respaldo, checksum_archivo, fecha_respaldo, observaciones | PK: id_respaldo |