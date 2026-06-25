# Entregable — Actividad 1

## Problemática

Una notaría requiere digitalizar su operación porque la gestión manual genera retrasos, pérdida de documentos y ausencia de trazabilidad legal.

## Objetos a digitalizar (L5–L9)

| # | Objeto | Descripción |
|---|--------|-------------|
| 1 | **Expedientes** | Carpetas que agrupan trámites de un cliente |
| 2 | **Actas** | Constancias notariales (comparecencia, identificación, asamblea) |
| 3 | **Contratos** | Instrumentos con monto, moneda y vigencia |
| 4 | **Clientes** | Personas físicas o morales con identificación única |
| 5 | **Firmas electrónicas** | Evidencia criptográfica sobre versiones de documentos |

## Situación actual (L12–L14)

| Problema | Efecto |
|----------|--------|
| **Retraso en búsquedas** | Localizar expedientes o documentos es lento sin índice unificado |
| **Riesgo de extravío documental** | Copias dispersas en archivos físicos y rutas digitales inconexas |
| **Falta de trazabilidad** | No se reconstruye quién modificó, firmó o respaldó cada documento |

## Requerimientos de alto nivel (L16–L20)

1. **Gestión documental** — centralizar actas, contratos y anexos
2. **Versionado** — versiones secuenciales; lo firmado no se edita
3. **Auditoría** — bitácora de operaciones con detalle estructurado
4. **Firma electrónica** — certificado + hash + notario
5. **Seguimiento de trámites** — estados visibles en todo el ciclo

## Temas relevantes (L22–L26)

| Tema | Cómo se materializa en el proyecto |
|------|-----------------------------------|
| Integridad y seguridad | FK, CHECK, hashes SHA-256 |
| XML | Columna `detalle_xml` en `Auditoria` + índice XML |
| Procedimientos almacenados | 6 SPs en `05-.../sql/03_stored_procedures.sql` |
| Control de acceso | Tablas `Usuario`, `Rol`, `UsuarioRol` |
| Respaldo documental | Tabla `Respaldo` con checksum por expediente |