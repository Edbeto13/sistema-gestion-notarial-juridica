# 3. Planteamiento del Problema

*Extensión orientativa: 2 cuartillas. Fuente: [`instruccionesv2.txt`](../instruccionesv2.txt) §3.*

## Situación actual

La notaría gestiona la memoria jurídica de sus actos mediante soportes físicos y prácticas heredadas del protocolo en papel:

- **Expedientes** en carpetas de cartulina que agrupan cronológicamente solicitudes, certificados, avalúos y hojas de cotejo. Solo un operador puede tener la carpeta abierta en un anaquel a la vez; el crecimiento del archivo incrementa la distancia física y el tiempo de recuperación.
- **Actas** empastadas en volúmenes de protocolo (bloques de 100–200 folios en papel de seguridad). Consultar un acta implica manipular el volumen completo y bloquea el acceso concurrente a otros instrumentos del mismo libro.
- **Contratos y escrituras** redactados en papel de seguridad con cláusulas financieras en prosa. Agregar montos totales o rastrear cláusulas exige lectura secuencial manual.
- **Clientes (comparecientes)** documentados en legajos repetidos por trámite: copias de INE, CURP, RFC y comprobantes de domicilio duplicados en cada expediente.
- **Firmas** manifestadas como trazos autógrafos, huella dactilar y sello en seco, sin vínculo criptográfico intrínseco al contenido de páginas intermedias.

Paralelamente coexisten copias digitales informales (PDF por correo, carpetas de red sin versionado) que **no reemplazan** al protocolo físico pero sí **duplican** la información sin gobernanza.

## Problemas detectados

| # | Problema | Manifestación operativa |
|---|----------|-------------------------|
| P1 | Retraso en búsquedas | Complejidad O(N) al recorrer carpetas y libros; sin índices de metadatos |
| P2 | Extravío y versión incorrecta | Múltiples copias mutables sin checksum ni expediente maestro |
| P3 | Falta de trazabilidad | Sin bitácora de quién cambió qué, ni historial de versiones firmadas |
| P4 | Redundancia de datos de clientes | Misma persona documentada N veces con riesgo de inconsistencia |
| P5 | Firma desacoplada del contenido | Alteración de páginas intermedias no detectable por la firma al calce |
| P6 | Respaldos no vinculados | Copias de seguridad sin relación formal con el expediente origen |

Los problemas P1–P3 coinciden con el enunciado [`instruccion.txt`](../instruccion.txt); P4–P6 se deducen del análisis documental por elemento (ver README de digitalización).

## Impacto en la organización

**Operativo:** tiempos de atención más largos, retrabajo en trámites y cuellos de botella cuando varios abogados requieren el mismo volumen de protocolo.

**Legal y probatorio:** debilidad para demostrar la secuencia exacta de versiones y firmas ante controversia o revisión de autoridad.

**Reputacional:** clientes corporativos perciben desorden cuando no hay seguimiento confiable del estado del trámite.

**Cumplimiento:** dificultad para acreditar control de acceso, custodia y protección de datos personales dispersos en legajos físicos.

**Económico:** horas-hombre en búsqueda manual y riesgo de pérdida de documentos que obligan a reconstitución costosa.

## Justificación del proyecto

> La notaría presenta inconsistencias y latencia en el control documental debido al manejo manual y fragmentado de expedientes, actas, contratos, legajos de clientes y evidencias de firma, ocasionando retrasos en la atención, riesgo de extravío y ausencia de trazabilidad que comprometen la fe pública y la eficiencia operativa.

El proyecto se justifica porque:

1. La fe pública exige **inmutabilidad** y **reconstrucción histórica** de cada acto — requisitos que un modelo relacional con versionado y auditoría XML satisface mejor que el papel.
2. La digitalización estructurada reduce la búsqueda de O(N) lineal a O(log N) mediante índices sobre folio, cliente, estado y hash.
3. La implementación en SQL Server con procedimientos almacenados encapsula reglas de negocio (cliente activo, versión firmada antes de nueva versión, certificado vigente) y reduce errores humanos.
4. Los archivos digitalizados de ejemplo (`archivos-digitalizados/`) demuestran la correspondencia entre el artefacto físico y su representación en base de datos, facilitando la transición pedagógica AS-IS → TO-BE.

**Evidencia de solución inicial:** scripts [`sql/01_create_database.sql`](../sql/01_create_database.sql) a [`sql/04_seed_data.sql`](../sql/04_seed_data.sql), desplegables en SSMS 22.7.0+.