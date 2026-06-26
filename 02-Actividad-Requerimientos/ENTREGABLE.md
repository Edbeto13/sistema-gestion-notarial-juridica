# Entregable — Actividad 2

## Información que debe almacenar el sistema (L29)

| Dominio | Información a persistir |
|---------|-------------------------|
| Identidad | Tipo de persona, nombre, identificación única, contacto, dirección, activo |
| Expedientes | Folio, cliente, fecha apertura, estado, observaciones |
| Trámites | Tipo, expediente, descripción, estado, fechas inicio/cierre |
| Documentos | Tipo, trámite, título, ruta, fecha creación |
| Actas / Contratos | Número de acta, tipo, lugar; monto, moneda, vigencia |
| Versionado | Número secuencial, resumen, hash, firmado, fecha |
| Firmas | Versión, usuario, hash firmado, certificado, fecha |
| Seguridad | Usuarios, roles, asignaciones, certificados |
| Auditoría | Tabla, operación, registro, usuario, XML, fecha |
| Respaldo | Expediente, ruta, checksum, fecha, observaciones |

## Requerimientos funcionales (L33)

| ID | Descripción |
|----|-------------|
| RF01 | Registrar clientes físicos o jurídicos con identificación única |
| RF02 | Crear y consultar expedientes asociados a un cliente |
| RF03 | Gestionar trámites con estados y fechas |
| RF04 | Almacenar documentos (actas, contratos, anexos) por trámite |
| RF05 | Controlar versiones inmutables de cada documento |
| RF06 | Buscar por folio, cliente, fecha o tipo |
| RF07 | Aplicar firma electrónica validando certificado y hash |
| RF08 | Registrar auditoría con detalle estructurado |
| RF09 | Programar y consultar respaldos por expediente |
| RF10 | Controlar acceso mediante usuarios y roles |
| RF11 | Exportar metadatos de auditoría en XML |
| RF12 | Seguimiento del ciclo de vida de cada trámite |
| RF13 | Registrar y validar certificados electrónicos de notarios |
| RF14 | Asignar y revocar roles a usuarios internos |
| RF15 | Consultar historial de versiones y firmas por documento |

> `instruccionesv2.txt` exige 15 RF; RF13–RF15 amplían el listado para la entrega final (ver `proyecto_final.pdf` §5).

## Requerimientos no funcionales (L34)

| ID | Descripción |
|----|-------------|
| RNF01 | Integridad: FK, CHECK, hashes SHA-256 |
| RNF02 | Seguridad: roles y certificados vigentes |
| RNF03 | Auditoría inmutable con XML |
| RNF04 | Rendimiento: índices en folio, estado, cliente, hash |
| RNF05 | Disponibilidad: respaldos con checksum |
| RNF06 | Trazabilidad completa de versiones y firmas |
| RNF07 | Escalabilidad: esquema en 3FN |
| RNF08 | XML indexado en auditoría |
| RNF09 | Operaciones críticas en procedimientos almacenados |
| RNF10 | Firma ligada a hash y certificado del notario |

## Usuarios del sistema (L35)

| Usuario | Responsabilidad |
|---------|-----------------|
| Notario | Autoriza actos, firma electrónica, cierra expedientes |
| Secretario | Registra clientes, expedientes, documentos y versiones |
| Cliente | Consulta limitada del estado de sus expedientes |
| Administrador | Usuarios, roles y respaldos |
| Auditor | Consulta bitácora sin modificar datos |

## Reglas de negocio (L36)

1. **RN01:** Todo expediente pertenece a un cliente activo.
2. **RN02:** Un documento firmado no se edita; solo nueva versión.
3. **RN03:** Firma exige certificado vigente y hash del documento.
4. **RN04:** Cambio de estado de trámite genera auditoría.
5. **RN05:** Solo el notario firma versiones finales.
6. **RN06:** Versiones secuenciales y no reutilizables.
7. **RN07:** Expediente activo debe tener respaldo documentado.
8. **RN08:** Acceso a documentos sensibles según rol.
9. **RN09:** La identificación del cliente es única en el sistema.
10. **RN10:** Un trámite pertenece a un solo expediente.
11. **RN11:** Una firma electrónica referencia exactamente una versión de documento.
12. **RN12:** Un certificado vencido no puede usarse para firmar.
13. **RN13:** El folio de expediente es único en todo el sistema.
14. **RN14:** Solo usuarios activos pueden operar en el sistema.
15. **RN15:** Todo respaldo registra checksum SHA-256 para verificación de integridad.

> `instruccionesv2.txt` exige 15 RN; RN09–RN15 en `proyecto_final.pdf` §6.

## Procesos principales (L37)

Registro de cliente → apertura de expediente → creación de trámite → carga de documento → versionado → firma electrónica → respaldo → consulta de auditoría.

**Diagrama:** `04-Actividad-Modelo-ER/diagramas/procesos_notaria.mmd` y `.png`