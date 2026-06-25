# Entregable — Actividad 4

## Diagrama E-R (L53)

- **Fuente editable:** `diagramas/er_notaria.mmd`
- **Imagen para revisión:** `diagramas/er_notaria.png`
- **Flujo de procesos (Act. 2):** `diagramas/procesos_notaria.png`

## Relaciones (L55)

| Relación | Participantes |
|----------|---------------|
| solicita | Cliente → Expediente |
| contiene | Expediente → Trámite |
| clasifica | TipoTramite → Trámite |
| genera | Trámite → Documento |
| versiona | Documento → VersionDocumento |
| especializa | Documento → Acta / Contrato |
| recibe | VersionDocumento → FirmaElectronica |
| autoriza | Usuario → FirmaElectronica |
| registra | Usuario → Auditoria |
| asigna | Usuario ↔ Rol (N:M vía UsuarioRol) |
| respalda | Expediente → Respaldo |

## Cardinalidades (L54)

| Relación | Cardinalidad | Justificación |
|----------|--------------|---------------|
| Cliente — Expediente | 1:N | Un cliente puede tener varios expedientes |
| Expediente — Trámite | 1:N | Un expediente agrupa múltiples trámites |
| TipoTramite — Trámite | 1:N | Catálogo reutilizable |
| Trámite — Documento | 1:N | Un trámite genera varios documentos |
| Documento — VersionDocumento | 1:N | Versionado obligatorio |
| Documento — Acta / Contrato | 1:0..1 | Especialización ISA |
| VersionDocumento — FirmaElectronica | 1:N | Varias firmas por versión |
| Usuario — Rol | N:M | Tabla UsuarioRol |
| Usuario — Auditoria | 1:N | Bitácora por operador |
| Expediente — Respaldo | 1:N | Historial de respaldos |

## Justificación del modelo (L56)

- **Expediente / Trámite / Documento** separados para trazabilidad operativa.
- **VersionDocumento** independiente permite auditoría y firma sin alterar revisiones previas.
- **Acta** y **Contrato** como especializaciones ISA evitan redundancia.
- **Usuario, Rol, Auditoria y Respaldo** materializan seguridad, control de acceso y cumplimiento.