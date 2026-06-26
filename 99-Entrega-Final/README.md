# Entrega final

## Documentos PDF

| Archivo | Enunciado | Uso |
|---------|-----------|-----|
| [`proyecto_final.pdf`](proyecto_final.pdf) | **`instruccionesv2.txt` §1–9** | **Entrega principal del proyecto final** |
| [`cuaderno-completo.pdf`](cuaderno-completo.pdf) | `instruccion.txt` act. 1–5 | Cuaderno de actividades del curso |

## Fuentes LaTeX

| Archivo | Descripción |
|---------|-------------|
| `fuentes/proyecto_final.txt` | Documento técnico completo (v2) |
| `fuentes/notaria_informe.txt` | Informe actividades 1–5 |
| `fuentes/build-iaparabd.ps1` | Compilación |

## Recompilar

```powershell
cd fuentes
powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode proyecto_final
copy ..\output\proyecto_final.pdf ..\proyecto_final.pdf
```

Para el cuaderno act. 1–5:

```powershell
powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode notaria
copy ..\output\notaria.pdf ..\cuaderno-completo.pdf
```