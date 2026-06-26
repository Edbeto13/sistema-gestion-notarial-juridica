# 4. Objetivos

*Fuente: [`instruccionesv2.txt`](../instruccionesv2.txt) §4.*

## Objetivo general

**Diseñar, implementar y documentar una base de datos relacional en Microsoft SQL Server** que digitalice la gestión de expedientes, actas, contratos, clientes y firmas electrónicas de una notaría, eliminando los problemas de retraso en búsquedas, extravío documental y falta de trazabilidad, mediante integridad referencial, versionado inmutable, auditoría estructurada en XML, control de acceso por roles y respaldo documental verificable.

*Responde a: ¿Qué se pretende resolver?* — La fragmentación y el riesgo operativo/legal del manejo analógico de la documentación notarial.

## Objetivos específicos

| # | Objetivo específico | Evidencia en el proyecto |
|---|-------------------|--------------------------|
| OE1 | **Digitalizar expedientes y trámites** con folio único, estados y vinculación al cliente | Tablas `Expediente`, `Tramite`; SP `sp_AbrirExpediente`, `sp_CambiarEstadoTramite` |
| OE2 | **Estructurar actas y contratos** sin duplicar atributos comunes de documentos | Tablas `Documento`, `Acta`, `Contrato` (especialización ISA) |
| OE3 | **Centralizar clientes** con identificación única y eliminar redundancia de legajos | Tabla `Cliente` con `UQ` en `identificacion` |
| OE4 | **Garantizar versionado y firma electrónica** con hash SHA-256 y certificado vigente | `VersionDocumento`, `FirmaElectronica`; SPs `sp_RegistrarVersionDocumento`, `sp_AplicarFirmaElectronica` |
| OE5 | **Implementar trazabilidad y respaldo** mediante auditoría XML y checksum por expediente | `Auditoria`, `Respaldo`; SPs `sp_RegistrarAuditoria`, `sp_EjecutarRespaldoExpediente` |
| OE6 | **Documentar la transición físico → digital** con archivos de ejemplo y análisis AS-IS/TO-BE | [`README-PROBLEMATICA-DIGITALIZACION.md`](../README-PROBLEMATICA-DIGITALIZACION.md), `archivos-digitalizados/` |

> El enunciado exige mínimo 5 objetivos específicos; se listan 6 para cubrir los cinco elementos core más la documentación de digitalización.