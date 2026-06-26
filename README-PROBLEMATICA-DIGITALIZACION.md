# Problemática inicial y transición a digitalización

**Sistema de Gestión Notarial y Jurídica** — Análisis AS-IS / TO-BE y archivos digitalizados de ejemplo.

| Referencia | Archivo |
|------------|---------|
| Enunciado actividades | [`instruccion.txt`](instruccion.txt) |
| Entrega final (secc. 1–4) | [`entrega-v2/`](entrega-v2/) |
| Implementación SSMS | [`sql/`](sql/) (scripts 01–04) |
| Archivos digitalizados | [`archivos-digitalizados/`](archivos-digitalizados/) |

---

## A. Propósito de este documento

Fundamentar **qué se digitaliza, por qué falla el modelo en papel y cómo la base de datos actual lo resuelve**, sin cambiar el esquema `notaria.*` implementado. El texto de ayuda académica que menciona `Instrumentos`, `Personas` o `FILESTREAM` se usa como **modelo conceptual**; la **implementación** permanece en las tablas existentes.

---

## B. Los cinco elementos: antes, después y solución

### B.1 Expedientes

| Aspecto | Detalle |
|---------|---------|
| **Antes (físico)** | Carpeta de cartulina manila o plástico denso que agrupa cronológicamente solicitudes, certificados de libertad de gravamen, avalúos, pagos de impuestos y hojas de cotejo. Integra la memoria histórica del trámite antes de autorizar el acto. |
| **Contenido típico** | Carta de solicitud del cliente, identificaciones, documentos del inmueble, borradores. |
| **Por qué es obligatorio** | La ley notarial exige acreditar prelación y cumplimiento de requisitos antes de la escritura. |
| **Después (digital)** | `notaria.Expediente` (folio, cliente, estado, observaciones) + `notaria.Tramite` (procedimientos dentro del expediente). |
| **Archivo digitalizado** | [`archivos-digitalizados/EXP-2026-0001/indice-expediente.json`](archivos-digitalizados/EXP-2026-0001/indice-expediente.json) |
| **Problemática que origina** | **Retraso en búsquedas** — acceso secuencial; un solo operador por carpeta; distancia en anaquel. |
| **Solución en BD** | `UQ` en `folio_expediente`; índices `IX_Expediente_Cliente`, `IX_Expediente_Estado`; SP `sp_AbrirExpediente` con auditoría XML. |

**Equivalencia conceptual:** expediente físico ≈ entidad maestra `Expediente`; trámites ≈ filas en `Tramite` (no tabla `ActoresExpediente` — roles se modelan vía `Cliente` + trámite).

---

### B.2 Actas

| Aspecto | Detalle |
|---------|---------|
| **Antes (físico)** | Instrumento en papel de seguridad foliado; hechos jurídicos, comparecencias, protestas. Firmas de testigos y certificación autógrafa del notario. Empastadas en **Volúmenes de Protocolo** (100–200 folios). |
| **Contenido típico** | Narrativa del hecho, identificación de comparecientes, lugar y fecha de celebración. |
| **Por qué es obligatorio** | Valor probatorio como instrumento público archivado en protocolo. |
| **Después (digital)** | `notaria.Documento` (`tipo_documento = 'ACTA'`) + `notaria.Acta` (`numero_acta`, `tipo_acta`, `lugar_celebracion`). |
| **Archivo digitalizado** | [`archivos-digitalizados/EXP-2026-0001/acta-comparecencia.pdf.txt`](archivos-digitalizados/EXP-2026-0001/acta-comparecencia.pdf.txt) |
| **Problemática que origina** | **Retraso** y bloqueo concurrente — consultar un folio implica manipular el volumen entero. |
| **Solución en BD** | Metadatos en tablas indexadas; contenido en `ruta_archivo`; búsqueda por `numero_acta` (`UQ`). |

**Equivalencia conceptual:** acta en protocolo ≈ `Documento` + especialización `Acta` (en lugar de `Instrumentos` con `TipoInstrumento = 'Acta'`).

---

### B.3 Contratos

| Aspecto | Detalle |
|---------|---------|
| **Antes (físico)** | Escritura pública con declaraciones de partes, antecedentes, cláusulas financieras, valor de operación. Papel de seguridad integrado al protocolo. |
| **Contenido típico** | Monto, moneda, vigencia, destino del bien, obligaciones. |
| **Por qué es obligatorio** | Formaliza actos bilaterales/multilaterales con fe pública. |
| **Después (digital)** | `notaria.Documento` + `notaria.Contrato` (`monto`, `moneda`, `vigencia_inicio`, `vigencia_fin`). |
| **Archivo digitalizado** | [`archivos-digitalizados/EXP-2026-0001/contrato-compraventa.pdf.txt`](archivos-digitalizados/EXP-2026-0001/contrato-compraventa.pdf.txt) |
| **Problemática que origina** | **Retraso** en agregación estadística; imposible sumar montos sin leer cada escritura. |
| **Solución en BD** | `DECIMAL(18,2)` en `Contrato`; consultas SQL sobre montos y vigencias. |

**Equivalencia conceptual:** `MetadatosContrato` del texto de ayuda ≈ tabla `Contrato` (ISA sobre `Documento`).

---

### B.4 Clientes (comparecientes)

| Aspecto | Detalle |
|---------|---------|
| **Antes (físico)** | Legajo impreso en apéndices: INE, CURP, RFC, acta de nacimiento, comprobante de domicilio. Se **replica** en cada expediente. |
| **Contenido típico** | Datos de identidad y capacidad jurídica. |
| **Por qué es obligatorio** | Acreditar identidad y legitimación de otorgantes. |
| **Después (digital)** | `notaria.Cliente` con `UQ` en `identificacion`; vinculación por `Expediente.id_cliente`. |
| **Archivo digitalizado** | [`archivos-digitalizados/clientes/CURP-PEMJ850101HDFRRN09.json`](archivos-digitalizados/clientes/CURP-PEMJ850101HDFRRN09.json) |
| **Problemática que origina** | **Extravío** e inconsistencia — múltiples copias del mismo cliente con errores de captura. |
| **Solución en BD** | Una fila por identificación; `CK` y `UQ`; validación en `sp_AbrirExpediente` (cliente activo). |

**Equivalencia conceptual:** `Personas` + `UQ_CURP/RFC` ≈ `Cliente.identificacion` UNIQUE.

---

### B.5 Firmas electrónicas (antes: autógrafas)

| Aspecto | Detalle |
|---------|---------|
| **Antes (físico)** | Tinta autógrafa al margen y calce, huella dactilar, sello en seco del notario. |
| **Contenido típico** | Manifestación de voluntad in situ. |
| **Por qué es obligatorio** | Autentica el instrumento y a la comparecencia. |
| **Después (digital)** | `notaria.FirmaElectronica` (`hash_firmado`, `certificado_serial`) + `VersionDocumento.firmado = 1`. |
| **Archivo digitalizado** | [`archivos-digitalizados/firmas/firma-version-2.xml`](archivos-digitalizados/firmas/firma-version-2.xml) |
| **Problemática que origina** | **Falta de trazabilidad** — alteración de páginas intermedias no reflejada en firma al calce. |
| **Solución en BD** | Hash SHA-256 por versión; SP `sp_AplicarFirmaElectronica` valida certificado vigente; firma ligada a `id_version`. |

**Equivalencia conceptual:** FEA / PKCS#7 del texto de ayuda ≈ registro en `FirmaElectronica` + hash en `VersionDocumento` (sin `VARBINARY(MAX)` de bloque CMS en esta fase).

---

## C. Matriz AS-IS → TO-BE (problemáticas del enunciado)

| Problemática (AS-IS) | Causa en papel | Requerimiento | Solución TO-BE (implementada) |
|----------------------|----------------|---------------|------------------------------|
| **Retraso en búsquedas** | Escaneo lineal O(N) de carpetas y libros | Gestión documental, seguimiento de trámites | Índices en folio, estado, cliente; consultas JOIN documentadas en [`sql/README_SSMS.md`](sql/README_SSMS.md) |
| **Riesgo de extravío documental** | Copias mutables sin checksum ni dueño único | Respaldo documental, integridad | `notaria.Respaldo` + `sp_EjecutarRespaldoExpediente`; rutas en `archivos-digitalizados/respaldos/` |
| **Falta de trazabilidad** | Sin bitácora de cambios ni versiones | Versionado, auditoría | `VersionDocumento` secuencial; `Auditoria.detalle_xml`; SPs con `TRY/CATCH` y transacciones |

---

## D. Requerimientos y temas relevantes (`instruccion.txt`)

| Enunciado | Mecanismo en el proyecto |
|-----------|--------------------------|
| Gestión documental | `Documento`, `ruta_archivo`, tipos ACTA/CONTRATO/ANEXO |
| Versionado | `VersionDocumento`, `UQ (id_documento, numero_version)`, SP versionado |
| Auditoría | `Auditoria`, índice XML `PXML_Auditoria_detalle` |
| Firma electrónica | `FirmaElectronica`, `sp_AplicarFirmaElectronica` |
| Seguimiento de trámites | `Tramite.estado`, `sp_CambiarEstadoTramite` |
| Integridad y seguridad | FK, CHECK, `HASHBYTES('SHA2_256', ...)` |
| XML | `detalle_xml` en auditoría |
| Procedimientos almacenados | 6 SPs en [`sql/03_stored_procedures.sql`](sql/03_stored_procedures.sql) |
| Control de acceso | `Usuario`, `Rol`, `UsuarioRol` |
| Respaldo documental | `Respaldo`, manifest JSON de ejemplo |

---

## E. Archivos digitalizados propuestos

| Ruta | Simula (antes) | Tabla BD |
|------|----------------|----------|
| `EXP-2026-0001/indice-expediente.json` | Carátula carpeta manila | `Expediente` |
| `EXP-2026-0001/acta-comparecencia.pdf.txt` | Folio en protocolo | `Documento` + `Acta` |
| `EXP-2026-0001/contrato-compraventa.pdf.txt` | Escritura con montos | `Documento` + `Contrato` |
| `clientes/CURP-*.json` | Legajo compareciente | `Cliente` |
| `firmas/firma-version-2.xml` | Firma autógrafa / evidencia FEA | `FirmaElectronica` |
| `respaldos/EXP-2026-0001.manifest.json` | Copia de carpeta en bodega | `Respaldo` |

Los archivos `.pdf.txt` son **placeholders pedagógicos** (sustituibles por PDF/A reales en producción).

---

## F. Despliegue en SSMS (evidencia TO-BE)

La BD está lista para SSMS ejecutando en orden:

1. [`sql/01_create_database.sql`](sql/01_create_database.sql)
2. [`sql/02_create_schema.sql`](sql/02_create_schema.sql)
3. [`sql/03_stored_procedures.sql`](sql/03_stored_procedures.sql)
4. [`sql/04_seed_data.sql`](sql/04_seed_data.sql)

Opcional: [`sql/05_generate_synthetic_data.sql`](sql/05_generate_synthetic_data.sql)

Instancia probada: `(localdb)\MSSQLLocalDB`. Ver [`sql/README_SSMS.md`](sql/README_SSMS.md).

---

## G. Alcance de entrega según `instruccionesv2.txt`

| Sección v2 | Estado | Ubicación |
|------------|--------|-----------|
| 1 Portada | Borrador con placeholders | [`entrega-v2/01-portada.md`](entrega-v2/01-portada.md) |
| 2 Introducción | Redactada (≥2 cuartillas orientativas) | [`entrega-v2/02-introduccion.md`](entrega-v2/02-introduccion.md) |
| 3 Planteamiento | Redactado (≥2 cuartillas orientativas) | [`entrega-v2/03-planteamiento-problema.md`](entrega-v2/03-planteamiento-problema.md) |
| 4 Objetivos | 1 general + 6 específicos | [`entrega-v2/04-objetivos.md`](entrega-v2/04-objetivos.md) |
| 5+ | Pendiente fase siguiente | — |

---

## H. Pasos de ejecución y responsabilidades

| Paso | Acción | Responsable |
|------|--------|-------------|
| 1 | Leer este README y `entrega-v2/` | Revisor / docente |
| 2 | Completar portada (`01-portada.md`) | **TU AYUDA** — datos institución, integrantes, docente |
| 3 | Validar realismo notarial del texto | **TU AYUDA** — revisión de dominio |
| 4 | Desplegar scripts 01–04 en SSMS | **AUTO** (o tú si usas otra instancia SQL) |
| 5 | Revisar archivos en `archivos-digitalizados/` | Ambos |
| 6 | Continuar con secciones 5–9 de `instruccionesv2.txt` | Fase posterior |

**Cobertura estimada:** ~90 % del contenido técnico y documental de las secciones 1–4 + problemática de `instruccion.txt` puede validarse sin intervención; la portada y la aprobación final requieren tus datos y revisión.