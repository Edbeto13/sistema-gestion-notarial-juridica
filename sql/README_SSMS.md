# Despliegue en SQL Server Management Studio 22.7.0

Base de datos de ejemplo para el **Sistema de Gestion Notarial y Juridica**.

## Requisitos

- SSMS 22.7.0 (o superior)
- SQL Server local: Express, Developer o 2025 (17.x)
- Instancia probada: `(localdb)\MSSQLLocalDB`

## Pasos en SSMS

1. Abrir SSMS y conectar a la instancia local.
2. Menu **Archivo > Abrir > Archivo** y cargar los scripts en este orden:
   - `01_create_database.sql`
   - `02_create_schema.sql`
   - `03_stored_procedures.sql`
   - `04_seed_data.sql`
   - `05_generate_synthetic_data.sql` *(opcional: volumen amplio de datos sinteticos)*
3. Ejecutar cada script con **F5** (o boton Ejecutar).
4. En Object Explorer verificar:
   - `NotariaJuridica > Tables > notaria.*`
   - `NotariaJuridica > Programmability > Stored Procedures`

## Despliegue por linea de comandos

```powershell
$server = "(localdb)\MSSQLLocalDB"
$sqlDir = "sql"
foreach ($f in "01_create_database.sql","02_create_schema.sql","03_stored_procedures.sql","04_seed_data.sql") {
    sqlcmd -S $server -E -i (Join-Path $sqlDir $f) -b
}
# Datos sinteticos adicionales (opcional)
sqlcmd -S $server -E -i (Join-Path $sqlDir "05_generate_synthetic_data.sql") -b
```

## Datos sinteticos (script 05)

El archivo `05_generate_synthetic_data.sql` genera volumen adicional respetando reglas de negocio via SPs.

Parametros editables al inicio del script:

| Parametro | Default | Descripcion |
|-----------|---------|-------------|
| `@num_clientes_nuevos` | 40 | Clientes a insertar |
| `@expedientes_min/max` | 1-3 | Expedientes por cliente |
| `@tramites_min/max` | 1-2 | Tramites por expediente |
| `@docs_min/max` | 1-3 | Documentos por tramite |
| `@versiones_max` | 3 | Versiones por documento |
| `@pct_firma` | 0.85 | Probabilidad de firmar ultima version |
| `@pct_respaldo` | 0.60 | Probabilidad de respaldo por expediente |

Alternativa en Python:

```powershell
cd IAparaBD\sql
python generate_synthetic_data.py --clientes 50 -o synthetic.sql
python generate_synthetic_data.py --clientes 50 --execute
```

## Datos de ejemplo esperados

| Entidad    | Registros |
|------------|-----------|
| Clientes   | 2         |
| Expedientes| 2         |
| Tramites   | 3         |
| Documentos | 3         |
| Versiones  | 2         |
| Firmas     | 2         |
| Auditorias | 8         |
| Respaldos  | 1         |

## Consulta de verificacion

```sql
USE NotariaJuridica;
SELECT e.folio_expediente, c.nombre_razon, t.estado, d.titulo, v.numero_version, v.firmado
FROM notaria.Expediente e
JOIN notaria.Cliente c ON c.id_cliente = e.id_cliente
JOIN notaria.Tramite t ON t.id_expediente = e.id_expediente
JOIN notaria.Documento d ON d.id_tramite = t.id_tramite
LEFT JOIN notaria.VersionDocumento v ON v.id_documento = d.id_documento;
```

## Procedimientos almacenados

- `notaria.sp_AbrirExpediente`
- `notaria.sp_RegistrarVersionDocumento`
- `notaria.sp_AplicarFirmaElectronica`
- `notaria.sp_CambiarEstadoTramite`
- `notaria.sp_RegistrarAuditoria`
- `notaria.sp_EjecutarRespaldoExpediente`