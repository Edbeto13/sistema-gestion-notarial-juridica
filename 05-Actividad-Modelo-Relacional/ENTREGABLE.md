# Entregable — Actividad 5

## Tablas propuestas (L63)

| Tabla | PK |
|-------|-----|
| notaria.Cliente | id_cliente |
| notaria.Expediente | id_expediente |
| notaria.TipoTramite | id_tipo_tramite |
| notaria.Tramite | id_tramite |
| notaria.Documento | id_documento |
| notaria.VersionDocumento | id_version |
| notaria.Acta | id_documento |
| notaria.Contrato | id_documento |
| notaria.Usuario | id_usuario |
| notaria.Rol | id_rol |
| notaria.UsuarioRol | (id_usuario, id_rol) |
| notaria.FirmaElectronica | id_firma |
| notaria.Auditoria | id_auditoria |
| notaria.Respaldo | id_respaldo |

## Claves foráneas y relaciones entre tablas (L65–L66)

| Tabla origen | FK | Tabla destino |
|--------------|-----|---------------|
| Expediente | id_cliente | Cliente |
| Tramite | id_expediente | Expediente |
| Tramite | id_tipo_tramite | TipoTramite |
| Documento | id_tramite | Tramite |
| VersionDocumento | id_documento | Documento |
| Acta | id_documento | Documento |
| Contrato | id_documento | Documento |
| UsuarioRol | id_usuario, id_rol | Usuario, Rol |
| FirmaElectronica | id_version, id_usuario | VersionDocumento, Usuario |
| Auditoria | id_usuario | Usuario |
| Respaldo | id_expediente | Expediente |

## Normalización (L57)

### Primera forma normal (1FN)
Atributos atómicos. Cada versión, firma y evento de auditoría ocupa su propia fila. El detalle variable de auditoría se almacena en un único campo XML bien formado.

### Segunda forma normal (2FN)
Sin dependencias parciales en claves compuestas (`UsuarioRol`, UQ en `VersionDocumento`). Atributos de `Contrato` y `Acta` dependen de la clave completa de su especialización.

### Tercera forma normal (3FN)
Sin dependencias transitivas: `TipoTramite` como catálogo; datos de cliente no se repiten en `Expediente`; especializaciones ISA separan atributos propios sin redundancia.

## Procedimientos almacenados

| SP | Función |
|----|---------|
| sp_AbrirExpediente | Crea expediente + auditoría XML |
| sp_RegistrarVersionDocumento | Nueva versión con hash SHA-256 |
| sp_AplicarFirmaElectronica | Valida certificado y firma |
| sp_CambiarEstadoTramite | Transición de estado + auditoría |
| sp_RegistrarAuditoria | Inserta evento XML |
| sp_EjecutarRespaldoExpediente | Registra respaldo con checksum |