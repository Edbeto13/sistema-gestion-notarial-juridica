# Sistema de Gestión Notarial y Jurídica

**Equipo BETAXIS** · Universidad de Negocios ISEC · Bases de Datos · 25 jun 2026

Repositorio cuaderno de revisión + entrega final del proyecto.

## Enunciados

| Archivo | Ubicación |
|---------|-----------|
| Actividades 1–5 | [`00-Enunciado/instruccion.txt`](00-Enunciado/instruccion.txt) |
| Proyecto final §1–9 | [`00-Enunciado/instruccionesv2.txt`](00-Enunciado/instruccionesv2.txt) |

## Cumplimiento

| Enunciado | Estado | Documento |
|-----------|--------|-----------|
| `instruccion.txt` | ✅ | [`GUIA-REVISION.md`](GUIA-REVISION.md) + carpetas `01`–`05` |
| `instruccionesv2.txt` | ✅ | [`CUMPLIMIENTO-INSTRUCCIONES-V2.md`](CUMPLIMIENTO-INSTRUCCIONES-V2.md) |

## Entregables finales (v2)

| # | Entregable | Archivo |
|---|------------|---------|
| 1 | **Documento técnico (PDF)** | [`99-Entrega-Final/proyecto_final.pdf`](99-Entrega-Final/proyecto_final.pdf) |
| 2 | **Script SQL completo** | [`05-Actividad-Modelo-Relacional/sql/NotariaJuridica_completo.sql`](05-Actividad-Modelo-Relacional/sql/NotariaJuridica_completo.sql) |
| 3 | **Diagrama E-R editable** | [`04-Actividad-Modelo-ER/diagramas/er_notaria.mmd`](04-Actividad-Modelo-ER/diagramas/er_notaria.mmd) |
| 4 | **Diccionario de datos** | [`entrega-v2/08-diccionario-datos.md`](entrega-v2/08-diccionario-datos.md) |

Índice detallado: [`entregables/README.md`](entregables/README.md)

## Cómo revisar (actividades 1–5)

1. Leer [`GUIA-REVISION.md`](GUIA-REVISION.md)
2. Recorrer carpetas `01-Actividad-Problematica` … `05-Actividad-Modelo-Relacional`
3. PDF integrado act. 1–5: [`99-Entrega-Final/cuaderno-completo.pdf`](99-Entrega-Final/cuaderno-completo.pdf)
4. PDF proyecto final v2: [`99-Entrega-Final/proyecto_final.pdf`](99-Entrega-Final/proyecto_final.pdf)

## Despliegue SQL (SSMS)

```powershell
# Opción A: script unificado
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "05-Actividad-Modelo-Relacional/sql/NotariaJuridica_completo.sql" -b

# Opción B: por partes (01 → 02 → 03 → 04)
$server = "(localdb)\MSSQLLocalDB"
$sqlDir = "05-Actividad-Modelo-Relacional/sql"
foreach ($f in "01_create_database.sql","02_create_schema.sql","03_stored_procedures.sql","04_seed_data.sql") {
    sqlcmd -S $server -E -i (Join-Path $sqlDir $f) -b
}
```

## Compilar PDFs

```powershell
# Proyecto final v2 (instruccionesv2.txt)
powershell -ExecutionPolicy Bypass -File 99-Entrega-Final/fuentes/build-iaparabd.ps1 -Mode proyecto_final

# Cuaderno actividades 1–5 (instruccion.txt)
powershell -ExecutionPolicy Bypass -File 99-Entrega-Final/fuentes/build-iaparabd.ps1 -Mode notaria
```

Ver [99-Entrega-Final/fuentes/README-build.md](99-Entrega-Final/fuentes/README-build.md).

## Estructura del cuaderno

```
00-Enunciado/          instruccion.txt + instruccionesv2.txt
01-Actividad-Problematica/
02-Actividad-Requerimientos/
03-Actividad-Entidades/
04-Actividad-Modelo-ER/    diagramas/er_notaria.mmd
05-Actividad-Modelo-Relacional/   sql/
entrega-v2/            secciones 1–9 (markdown)
99-Entrega-Final/      proyecto_final.pdf + cuaderno-completo.pdf
archivos-digitalizados/
```

## Fuera de alcance (equipo)

- Video demostrativo
- Presentación ejecutiva

## Licencia

Proyecto académico. Uso libre con atribución.