# Guía de revisión del cuaderno

Este repositorio está organizado como **cuaderno de entrega** para revisión académica. Cada carpeta corresponde a una actividad del enunciado (`00-Enunciado/instruccion.txt`).

## Cómo revisar

1. Abra `00-Enunciado/instruccion.txt`.
2. Recorra las carpetas `01` a `05` en orden.
3. En cada carpeta lea `README.md` (criterios) y `ENTREGABLE.md` (respuesta).
4. Marque el checklist del revisor al final de cada `README.md`.
5. Consulte `99-Entrega-Final/cuaderno-completo.pdf` como documento integrado.
6. Valide la implementación en `05-Actividad-Modelo-Relacional/sql/`.

## Mapa enunciado → evidencia

| Línea | Enunciado | Carpeta | Archivo principal |
|------:|-----------|---------|-------------------|
| 1–26 | Actividad 1 — Problemática y contexto | `01-Actividad-Problematica/` | `ENTREGABLE.md` |
| 28–37 | Actividad 2 — Requerimientos | `02-Actividad-Requerimientos/` | `ENTREGABLE.md` |
| 38–46 | Actividad 3 — Entidades | `03-Actividad-Entidades/` | `ENTREGABLE.md` |
| 48–56 | Actividad 4 — Modelo E-R | `04-Actividad-Modelo-ER/` | `ENTREGABLE.md` + diagramas |
| 57–66 | Actividad 5 — Modelo relacional y normalización | `05-Actividad-Modelo-Relacional/` | `ENTREGABLE.md` + `sql/` |
| — | Documento completo PDF | `99-Entrega-Final/` | `cuaderno-completo.pdf` |

## Detalle línea por línea

### Actividad 1 (líneas 1–26)

| Línea | Punto del enunciado | Evidencia |
|------:|---------------------|-----------|
| 1 | Título de la actividad | `01-Actividad-Problematica/README.md` |
| 2–3 | Problemática | `01-.../ENTREGABLE.md` § Problemática |
| 5 | Expedientes | `01-.../ENTREGABLE.md`, `sql/02_create_schema.sql` |
| 6 | Actas | `01-.../ENTREGABLE.md`, tabla `notaria.Acta` |
| 7 | Contratos | `01-.../ENTREGABLE.md`, tabla `notaria.Contrato` |
| 8 | Clientes | `01-.../ENTREGABLE.md`, tabla `notaria.Cliente` |
| 9 | Firmas electrónicas | `01-.../ENTREGABLE.md`, `notaria.FirmaElectronica` |
| 12 | Retraso en búsquedas | `01-.../ENTREGABLE.md` § Situación actual |
| 13 | Riesgo de extravío | `01-.../ENTREGABLE.md` § Situación actual |
| 14 | Falta de trazabilidad | `01-.../ENTREGABLE.md` § Situación actual |
| 16 | Gestión documental | `01-.../ENTREGABLE.md` § Requerimientos |
| 17 | Versionado | `01-.../ENTREGABLE.md` § Requerimientos |
| 18 | Auditoría | `01-.../ENTREGABLE.md` § Requerimientos |
| 19 | Firma electrónica | `01-.../ENTREGABLE.md` § Requerimientos |
| 20 | Seguimiento de trámites | `01-.../ENTREGABLE.md` § Requerimientos |
| 22 | Integridad y seguridad | `01-.../ENTREGABLE.md` § Temas relevantes |
| 23 | XML | `01-.../ENTREGABLE.md`, `Auditoria.detalle_xml` |
| 24 | Procedimientos almacenados | `01-.../ENTREGABLE.md`, `sql/03_*.sql` |
| 25 | Control de acceso | `01-.../ENTREGABLE.md`, tablas Usuario/Rol |
| 26 | Respaldo documental | `01-.../ENTREGABLE.md`, tabla `Respaldo` |

### Actividad 2 (líneas 28–37)

| Línea | Entregable | Evidencia |
|------:|------------|-----------|
| 29 | Información a almacenar | `02-.../ENTREGABLE.md` § Información |
| 33 | RF | `02-.../ENTREGABLE.md` § RF01–RF12 |
| 34 | RNF | `02-.../ENTREGABLE.md` § RNF01–RNF10 |
| 35 | Usuarios | `02-.../ENTREGABLE.md` § Usuarios |
| 36 | Reglas de negocio | `02-.../ENTREGABLE.md` § RN01–RN08 |
| 37 | Procesos principales | `02-.../ENTREGABLE.md`, `04-.../diagramas/procesos_notaria.*` |

### Actividad 3 (líneas 38–46)

| Línea | Entregable | Evidencia |
|------:|------------|-----------|
| 43 | Lista de entidades | `03-.../ENTREGABLE.md` |
| 44 | Descripción | `03-.../ENTREGABLE.md` columna Descripción |
| 45 | Atributos principales | `03-.../ENTREGABLE.md` columna Atributos |
| 46 | Claves | `03-.../ENTREGABLE.md` columna Claves |

### Actividad 4 (líneas 48–56)

| Línea | Entregable | Evidencia |
|------:|------------|-----------|
| 49 | E-R con atributos y cardinalidades | `04-.../diagramas/er_notaria.mmd` |
| 53 | Diagrama E-R | `04-.../diagramas/er_notaria.png` |
| 54 | Cardinalidades | `04-.../ENTREGABLE.md` |
| 55 | Relaciones | `04-.../ENTREGABLE.md` |
| 56 | Justificación | `04-.../ENTREGABLE.md` § Justificación |

### Actividad 5 (líneas 57–66)

| Línea | Entregable | Evidencia |
|------:|------------|-----------|
| 57 | Normalización | `05-.../ENTREGABLE.md` § 1FN/2FN/3FN |
| 59 | Conversión E-R → relacional | `05-.../ENTREGABLE.md`, `sql/02_*.sql` |
| 63 | Tablas propuestas | `05-.../ENTREGABLE.md` |
| 64 | Claves primarias | `05-.../ENTREGABLE.md`, `sql/02_*.sql` |
| 65 | Claves foráneas | `05-.../ENTREGABLE.md` |
| 66 | Relaciones entre tablas | `05-.../ENTREGABLE.md`, consulta en `sql/README_SSMS.md` |