# Actividad 5 — Modelo relacional y normalización

**Enunciado:** líneas 57–66 de `00-Enunciado/instruccion.txt`  
**Segundo parcial:** modelo relacional y normalización (L57)

## Qué revisar

| Línea | Entregable | Archivo |
|------:|------------|---------|
| 57 | Normalización | `ENTREGABLE.md` § Normalización |
| 59 | Conversión E-R → tablas | `ENTREGABLE.md` + `sql/02_create_schema.sql` |
| 63 | Tablas propuestas | `ENTREGABLE.md` § Tablas |
| 64 | Claves primarias | `ENTREGABLE.md`, `sql/02_*.sql` |
| 65 | Claves foráneas | `ENTREGABLE.md` § FK |
| 66 | Relaciones entre tablas | `ENTREGABLE.md` § FK + consulta en `sql/README_SSMS.md` |

## Implementación ejecutable

```powershell
$sqlDir = "sql"
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "$sqlDir\01_create_database.sql" -b
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "$sqlDir\02_create_schema.sql" -b
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "$sqlDir\03_stored_procedures.sql" -b
sqlcmd -S "(localdb)\MSSQLLocalDB" -E -i "$sqlDir\04_seed_data.sql" -b
```

## Checklist del revisor

- [ ] L57 Análisis 1FN, 2FN y 3FN presente
- [ ] L63 14 tablas en esquema `notaria`
- [ ] L64 PK en cada tabla
- [ ] L65 FK coherentes con el diagrama E-R
- [ ] L66 Relaciones verificables con JOIN
- [ ] Scripts SQL ejecutan sin error en SSMS