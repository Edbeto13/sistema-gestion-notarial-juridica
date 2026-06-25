# Sistema de Gestión Notarial y Jurídica

Proyecto académico de diseño e implementación de base de datos para digitalizar la operación de una notaría: expedientes, actas, contratos, clientes, firmas electrónicas, auditoría y respaldo documental.

Cubre las **actividades 1 a 5** del enunciado (`instruccion.txt`): entendimiento del negocio, requerimientos, entidades, modelo E-R, modelo relacional y normalización.

## Contenido del repositorio

| Carpeta / archivo | Descripción |
|-------------------|-------------|
| `instruccion.txt` | Enunciado de las actividades |
| `cumplimiento_instruccion.txt` | Checklist línea por línea del enunciado |
| `actividad1_entendimiento_negocio.txt` | Actividad 1 — análisis del negocio (LaTeX) |
| `notaria_informe.txt` | Informe principal actividades 1–5 (LaTeX) |
| `output/notaria.pdf` | PDF del informe notarial |
| `diagramas/` | Diagramas Mermaid (E-R y procesos) |
| `assets/diagramas/` | PNG exportados de los diagramas |
| `sql/` | Scripts T-SQL para SQL Server |
| `build-iaparabd.ps1` | Compilación de PDFs con LuaLaTeX |

## Base de datos

- **Motor:** SQL Server (SSMS 22.7.0+)
- **Base de datos:** `NotariaJuridica`
- **Esquema:** `notaria` (14 tablas)
- **Procedimientos:** 6 SPs de negocio con auditoría XML

### Despliegue rápido

```powershell
$server = "(localdb)\MSSQLLocalDB"
$sqlDir = "sql"
foreach ($f in "01_create_database.sql","02_create_schema.sql","03_stored_procedures.sql","04_seed_data.sql") {
    sqlcmd -S $server -E -i (Join-Path $sqlDir $f) -b
}
# Datos sintéticos adicionales (opcional)
sqlcmd -S $server -E -i (Join-Path $sqlDir "05_generate_synthetic_data.sql") -b
```

Documentación detallada en [`sql/README_SSMS.md`](sql/README_SSMS.md).

### Scripts SQL

| Script | Función |
|--------|---------|
| `01_create_database.sql` | Crea BD y esquema |
| `02_create_schema.sql` | Tablas, índices, restricciones |
| `03_stored_procedures.sql` | SPs de negocio |
| `04_seed_data.sql` | Datos mínimos de demostración |
| `05_generate_synthetic_data.sql` | Generador de datos sintéticos |
| `generate_synthetic_data.py` | Alternativa Python al script 05 |

## Modelo de datos

**Entidades principales:** Cliente, Expediente, Trámite, Documento, VersiónDocumento, Acta, Contrato, Usuario, Rol, FirmaElectronica, Auditoria, Respaldo.

**Reglas de negocio implementadas en SPs:**
- Un documento firmado no se edita; solo se crean versiones secuenciales.
- La firma exige certificado vigente y hash SHA-256 del contenido.
- Cada operación crítica registra auditoría con detalle XML.

## Compilar el informe PDF

Requisitos: MiKTeX o TeX Live, `lualatex`, `latexmk`, fuente Noto Sans (opcional).

```powershell
powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode notaria
```

Más opciones en [`README-build.md`](README-build.md).

## Consulta de verificación

```sql
USE NotariaJuridica;
SELECT e.folio_expediente, c.nombre_razon, t.estado, d.titulo, v.numero_version, v.firmado
FROM notaria.Expediente e
JOIN notaria.Cliente c ON c.id_cliente = e.id_cliente
JOIN notaria.Tramite t ON t.id_expediente = e.id_expediente
JOIN notaria.Documento d ON d.id_tramite = t.id_tramite
LEFT JOIN notaria.VersionDocumento v ON v.id_documento = d.id_documento;
```

## Estructura del proyecto

```
.
├── instruccion.txt
├── notaria_informe.txt
├── actividad1_entendimiento_negocio.txt
├── cumplimiento_instruccion.txt
├── diagramas/
│   ├── er_notaria.mmd
│   └── procesos_notaria.mmd
├── assets/diagramas/
├── sql/
├── output/
│   └── notaria.pdf
├── build-iaparabd.ps1
└── README.md
```

## Autor

Equipo de Análisis de Datos — Ciclo 2025–2026

## Licencia

Proyecto académico. Uso libre con atribución.