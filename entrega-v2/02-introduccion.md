# 2. Introducción

*Extensión orientativa: 2 cuartillas. Fuente: [`instruccionesv2.txt`](../instruccionesv2.txt) §2.*

## Contexto de la organización

La notaría es una institución de fe pública cuya función es formalizar actos jurídicos mediante instrumentos notariales con valor probatorio. En su operación cotidiana atiende a personas físicas y morales que requieren servicios como escrituras de compraventa, poderes, actas de comparecencia, constitución de sociedades y contratos mercantiles o civiles. Cada servicio genera un volumen documental considerable: solicitudes, identificaciones oficiales, avalúos, comprobantes fiscales, borradores, versiones corregidas y el instrumento definitivo firmado por el notario.

Históricamente, la notaría ha custodiado esta información en soportes físicos: carpetas de cartulina (expedientes), libros de protocolo empastados (actas y escrituras), legajos de comparecientes y archivos de tramitación en anaqueles. El notario y su equipo de secretaría coordinan la captura, revisión, firma y archivo de cada documento bajo normativa que exige conservación, integridad y trazabilidad a largo plazo.

En el escenario de este proyecto, la organización opera con procesos mayormente analógicos o con herramientas digitales aisladas (carpetas de red, correos con adjuntos, hojas de cálculo) que no constituyen una fuente única de verdad. La presión por tiempos de respuesta, auditorías y clientes corporativos que exigen seguimiento en línea hace insostenible el modelo exclusivamente físico.

## Problemática identificada

El enunciado del curso señala que la notaría debe digitalizar **expedientes, actas, contratos, clientes y firmas electrónicas**, pero enfrenta tres dolores estructurales:

1. **Retraso en búsquedas:** localizar un expediente, acta o contrato implica recorrer anaquel físico o carpetas sin índice unificado; las consultas por folio, cliente o fecha son lentas.
2. **Riesgo de extravío documental:** copias impresas, PDF sueltos y correos dispersos aumentan la probabilidad de pérdida o de trabajar con una versión incorrecta.
3. **Falta de trazabilidad:** no existe bitácora confiable de quién modificó un documento, cuándo se firmó ni qué respaldos se generaron.

Estas problemáticas se analizan documento por documento —qué se entrega en papel, qué contiene y por qué— en [`README-PROBLEMATICA-DIGITALIZACION.md`](../README-PROBLEMATICA-DIGITALIZACION.md).

## Importancia de la solución propuesta

Digitalizar no es solo escanear papeles: implica diseñar una **capa de persistencia** que modele el ciclo de vida documental, garantice integridad (claves foráneas, hashes, certificados), registre auditoría en XML, controle acceso por roles y vincule respaldos verificables a cada expediente. Sin esta base de datos, cualquier aplicación futura seguiría reproduciendo fragmentación y riesgo legal.

La solución en SQL Server (`NotariaJuridica`, esquema `notaria`) materializa los requerimientos de gestión documental, versionado, auditoría, firma electrónica y seguimiento de trámites definidos en [`instruccion.txt`](../instruccion.txt). Los scripts `sql/01`–`04` desplegables en SSMS constituyen la evidencia técnica de la etapa inicial de implementación.

## Alcance del proyecto

**Incluye:**

- Análisis AS-IS / TO-BE de los cinco elementos core del enunciado.
- Diseño e implementación de 14 tablas, 6 procedimientos almacenados e índices.
- Generación de archivos digitalizados de ejemplo en `archivos-digitalizados/`.
- Documentación de entrega según `instruccionesv2.txt` **secciones 1 a 4** (este cuaderno) y problemática detallada en el README de digitalización.

**Excluye (fase actual):**

- Portal web o aplicación móvil para clientes.
- Integración con plataformas gubernamentales de e.firma avanzada.
- Migración a modelo conceptual alternativo (`Instrumentos`, `FILESTREAM`) — se documenta equivalencia con el esquema `notaria.*` vigente.