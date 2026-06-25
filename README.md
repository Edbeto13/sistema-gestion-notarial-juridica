# Cuaderno — Sistema de Gestión Notarial y Jurídica

**Repositorio de entrega académica** organizado para revisión punto por punto según el enunciado.

| Dato | Valor |
|------|-------|
| Equipo | Análisis de Datos |
| Ciclo | 2025–2026 |
| Motor BD | SQL Server (SSMS 22.7.0) |
| Base de datos | `NotariaJuridica` / esquema `notaria` |

## Inicio rápido para el revisor

1. Lea la guía: **[GUIA-REVISION.md](GUIA-REVISION.md)**
2. Abra el enunciado: **[00-Enunciado/instruccion.txt](00-Enunciado/instruccion.txt)**
3. Revise las actividades en orden (`01` → `05`)
4. Consulte el PDF integrado: **[99-Entrega-Final/cuaderno-completo.pdf](99-Entrega-Final/cuaderno-completo.pdf)**

## Estructura del cuaderno

```
.
├── GUIA-REVISION.md              ← Mapa línea por línea del enunciado
├── 00-Enunciado/
│   └── instruccion.txt
├── 01-Actividad-Problematica/
│   ├── README.md                 ← Criterios y checklist del revisor
│   └── ENTREGABLE.md
├── 02-Actividad-Requerimientos/
├── 03-Actividad-Entidades/
├── 04-Actividad-Modelo-ER/
│   └── diagramas/
├── 05-Actividad-Modelo-Relacional/
│   └── sql/
└── 99-Entrega-Final/
    ├── cuaderno-completo.pdf
    └── fuentes/
```

## Implementación (validación técnica)

```powershell
$server = "(localdb)\MSSQLLocalDB"
$sqlDir = "05-Actividad-Modelo-Relacional/sql"
foreach ($f in "01_create_database.sql","02_create_schema.sql","03_stored_procedures.sql","04_seed_data.sql") {
    sqlcmd -S $server -E -i (Join-Path $sqlDir $f) -b
}
```

## Compilar el PDF del cuaderno

```powershell
powershell -ExecutionPolicy Bypass -File 99-Entrega-Final/fuentes/build-iaparabd.ps1 -Mode notaria
```

Ver [99-Entrega-Final/fuentes/README-build.md](99-Entrega-Final/fuentes/README-build.md).

## Licencia

Proyecto académico. Uso libre con atribución.