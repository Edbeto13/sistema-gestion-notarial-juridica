# Entrega final del cuaderno

Documento integrado que reúne las actividades 1 a 5 en un solo informe.

| Archivo | Descripción |
|---------|-------------|
| `cuaderno-completo.pdf` | Informe compilado para lectura continua |
| `fuentes/notaria_informe.txt` | Fuente LaTeX del informe completo |
| `fuentes/build-iaparabd.ps1` | Script de compilación |

## Recompilar el PDF

```powershell
cd fuentes
powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode notaria
copy ..\output\notaria.pdf ..\cuaderno-completo.pdf
```

El PDF generado se copia manualmente a esta carpeta como `cuaderno-completo.pdf`.