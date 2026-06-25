# Build guide for IAparaBD

This folder builds three PDFs:
- A report PDF derived from `informe.txt`.
- A Beamer slide deck derived from `presentacion.txt`.
- A notarial database design report derived from `notaria_informe.txt`.

## Sources vs derived files
- Sources (do not modify during build):
  - `informe.txt`
  - `instruccion.txt`
  - `presentacion.txt`
  - `notaria_informe.txt`
  - `diagramas/*.mmd`
- Derived files (auto-generated):
  - `build/informe.tex`
  - `build/presentacion.tex`

## Prerequisites
- MiKTeX or TeX Live with `lualatex` available in PATH
- `latexmk` available in PATH
- Noto Sans font installed in Windows (preferred by `fontspec` settings)

Note: The templates use `babel` with `bidi=basic`, which is supported with LuaLaTeX.
If Noto Sans is not found, the build script applies `Latin Modern Sans` as a fallback in derived files only.

## Outputs
- Final PDFs are copied to `output/`:
  - `informe.pdf`
  - `presentacion.pdf`
  - `notaria.pdf`

## Commands
From the repository root:

- Build both:
  `powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode all`

- Build only report:
  `powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode informe`

- Build only slides:
  `powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode presentacion`

- Build only notarial report:
  `powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode notaria`

- Clean and rebuild:
  `powershell -ExecutionPolicy Bypass -File build-iaparabd.ps1 -Mode all -Clean`

## Notes
- The build script fixes Markdown-style artifacts (e.g., `**bold**`) in the derived report file only.