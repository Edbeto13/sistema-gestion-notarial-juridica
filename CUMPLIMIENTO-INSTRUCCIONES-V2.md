# Cumplimiento — `instruccionesv2.txt`

Equipo **BETAXIS** · Universidad de Negocios ISEC · 25 de junio de 2026  
Repositorio: https://github.com/Edbeto13/sistema-gestion-notarial-juridica

> **Video y presentación ejecutiva:** fuera de alcance del repo (a cargo del equipo).

## Resumen

| Enunciado | Estado | Evidencia principal |
|-----------|--------|---------------------|
| `instruccion.txt` (act. 1–5) | **Cumple** | Carpetas `01`–`05`, `GUIA-REVISION.md`, `99-Entrega-Final/cuaderno-completo.pdf` |
| `instruccionesv2.txt` (§1–9) | **Cumple** | `99-Entrega-Final/proyecto_final.pdf` + archivos en `entrega-v2/` |

## Matriz §1–9 (`instruccionesv2.txt`)

| § | Requisito | Mínimo | Cumple | Evidencia |
|---|-----------|--------|:------:|-----------|
| 1 | Portada (institución, carrera, materia, título, equipo, integrantes, docente, fecha) | 8 campos | ✅ | `entrega-v2/01-portada.md` · PDF p. portada |
| 2 | Introducción (contexto, problemática, importancia, alcance) | 2 cuartillas | ✅ | `entrega-v2/02-introduccion.md` · PDF §2 |
| 3 | Planteamiento (situación actual, problemas, impacto, justificación) | 2 cuartillas | ✅ | `entrega-v2/03-planteamiento-problema.md` · PDF §3 |
| 4 | Objetivos (1 general + ≥5 específicos) | 6 total | ✅ | `entrega-v2/04-objetivos.md` · PDF §4 (1+6) |
| 5 | Requerimientos funcionales | 15 | ✅ | PDF §5 RF01–RF15 · `02-Actividad-Requerimientos/ENTREGABLE.md` |
| 5 | Requerimientos no funcionales | 10 | ✅ | PDF §5 RNF01–RNF10 |
| 6 | Reglas de negocio | 15 | ✅ | PDF §6 RN01–RN15 |
| 7 | Modelo E-R (entidades, atributos, relaciones, cardinalidades, PK) | Diagrama completo | ✅ | `04-Actividad-Modelo-ER/diagramas/er_notaria.mmd` · PDF §7 |
| 8 | Diccionario de datos (todas las tablas) | 14 tablas | ✅ | `entrega-v2/08-diccionario-datos.md` · PDF §8 |
| 9 | Modelo relacional (tablas, PK, FK, relaciones) | Completo | ✅ | PDF §9 · `05-Actividad-Modelo-Relacional/ENTREGABLE.md` |

## Entregables técnicos del repo

| Entregable | Archivo |
|------------|---------|
| Documento técnico completo (PDF) | [`99-Entrega-Final/proyecto_final.pdf`](99-Entrega-Final/proyecto_final.pdf) |
| Script SQL completo | [`05-Actividad-Modelo-Relacional/sql/NotariaJuridica_completo.sql`](05-Actividad-Modelo-Relacional/sql/NotariaJuridica_completo.sql) |
| Diagrama E-R editable | [`04-Actividad-Modelo-ER/diagramas/er_notaria.mmd`](04-Actividad-Modelo-ER/diagramas/er_notaria.mmd) |
| Diccionario de datos | [`entrega-v2/08-diccionario-datos.md`](entrega-v2/08-diccionario-datos.md) |

## Implementación (objetivo general del curso)

| Criterio del enunciado v2 | Evidencia |
|---------------------------|-----------|
| Análisis y diseño | Actividades 1–4, `proyecto_final.pdf` |
| Implementación SQL | BD `NotariaJuridica`, 14 tablas, 6 SPs |
| Integridad y seguridad | FK, CHECK, hashes, certificados, roles |
| Gestión de transacciones | SPs con `BEGIN TRAN` / `XACT_ABORT` |
| Normalización | 3FN documentada en PDF §9 |
| Explotación | `04_seed_data.sql`, consultas de verificación |

## Notas para el revisor

1. **Dos PDFs:** `cuaderno-completo.pdf` cubre `instruccion.txt` (act. 1–5); `proyecto_final.pdf` cubre `instruccionesv2.txt` (§1–9). Para la entrega final del curso, usar **`proyecto_final.pdf`**.
2. **Extensión impresa:** intro y planteamiento están redactados para ~2 cuartillas; conviene revisar en impresión antes de entregar.
3. **Fuera de alcance repo:** video demostrativo y presentación ejecutiva (equipo BETAXIS).