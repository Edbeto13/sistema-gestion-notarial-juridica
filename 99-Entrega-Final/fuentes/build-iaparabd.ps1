param(
    [ValidateSet("all", "informe", "presentacion", "notaria", "proyecto_final")]
    [string]$Mode = "all",
    [switch]$Clean
)

$ErrorActionPreference = "Stop"

$rootDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$buildDir = Join-Path $rootDir "build"
$outputDir = Join-Path $rootDir "output"
$assetsDir = Join-Path $rootDir "assets\diagramas"
$diagramasDir = Join-Path $rootDir "diagramas"

function Test-Tool {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Name
    )

    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $cmd) {
        throw "Required tool '$Name' was not found in PATH."
    }
}

function Invoke-MermaidRender {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null

    $mmdc = Get-Command mmdc -ErrorAction SilentlyContinue
    if (-not $mmdc) {
        $npx = Get-Command npx -ErrorAction SilentlyContinue
        if ($npx) {
            Write-Host "Rendering Mermaid diagrams via npx @mermaid-js/mermaid-cli..."
            foreach ($diagram in Get-ChildItem $diagramasDir -Filter "*.mmd") {
                $outFile = Join-Path $assetsDir ($diagram.BaseName + ".png")
                & npx --yes @mermaid-js/mermaid-cli -i $diagram.FullName -o $outFile -b transparent
                if ($LASTEXITCODE -ne 0) {
                    Write-Warning "Failed to render $($diagram.Name). PDF will use Mermaid source fallback."
                }
            }
            return
        }

        Write-Warning "mmdc/npx not found. Skipping Mermaid PNG render; PDF will reference .mmd sources."
        return
    }

    Write-Host "Rendering Mermaid diagrams via mmdc..."
    foreach ($diagram in Get-ChildItem $diagramasDir -Filter "*.mmd") {
        $outFile = Join-Path $assetsDir ($diagram.BaseName + ".png")
        & mmdc -i $diagram.FullName -o $outFile -b transparent
        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Failed to render $($diagram.Name). PDF will use Mermaid source fallback."
        }
    }
}

function Apply-FontFallback {
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$TexFiles
    )

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    $notoFonts = Get-ChildItem (Join-Path $env:WINDIR "Fonts\NotoSans*") -ErrorAction SilentlyContinue
    if (-not $notoFonts) {
        Write-Warning "Noto Sans was not found in Windows fonts. Applying fallback font Latin Modern Sans to derived files."
        foreach ($texFile in $TexFiles) {
            if (-not (Test-Path $texFile)) { continue }
            $content = [System.IO.File]::ReadAllText($texFile, [System.Text.Encoding]::UTF8)
            $content = $content -replace 'Noto Sans', 'Latin Modern Sans'
            [System.IO.File]::WriteAllText($texFile, $content, $utf8NoBom)
        }
    }
}

function New-Derivatives {
    $reportTex = Join-Path $buildDir "informe.tex"
    $slidesTex = Join-Path $buildDir "presentacion.tex"
    $notariaTex = Join-Path $buildDir "notaria.tex"
    $proyectoFinalTex = Join-Path $buildDir "proyecto_final.tex"

    Copy-Item (Join-Path $rootDir "informe.txt") $reportTex -Force
    Copy-Item (Join-Path $rootDir "presentacion.txt") $slidesTex -Force

    if (Test-Path (Join-Path $rootDir "notaria_informe.txt")) {
        Copy-Item (Join-Path $rootDir "notaria_informe.txt") $notariaTex -Force
    }
    if (Test-Path (Join-Path $rootDir "proyecto_final.txt")) {
        Copy-Item (Join-Path $rootDir "proyecto_final.txt") $proyectoFinalTex -Force
    }

    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)

    $reportContent = [System.IO.File]::ReadAllText($reportTex, [System.Text.Encoding]::UTF8)
    $reportContent = [System.Text.RegularExpressions.Regex]::Replace(
        $reportContent,
        '\*\*([^*\r\n]+)\*\*',
        '\textbf{$1}'
    )
    $reportContent = [System.Text.RegularExpressions.Regex]::Replace(
        $reportContent,
        '\(\*([^*\r\n]+)\*\)',
        '(\textit{$1})'
    )
    $reportContent = $reportContent -replace '\*self-driving\*', '\textit{self-driving}'
    [System.IO.File]::WriteAllText($reportTex, $reportContent, $utf8NoBom)

    $fontTexFiles = @($reportTex, $slidesTex, $notariaTex)
    if (Test-Path $proyectoFinalTex) { $fontTexFiles += $proyectoFinalTex }
    Apply-FontFallback -TexFiles $fontTexFiles
}

function Build-One {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FileName
    )

    Write-Host "Compiling $FileName with latexmk (LuaLaTeX)..."
    Push-Location $buildDir
    try {
        & latexmk -lualatex -interaction=nonstopmode -halt-on-error $FileName
        if ($LASTEXITCODE -ne 0) {
            throw "latexmk failed for $FileName with exit code $LASTEXITCODE."
        }
    }
    finally {
        Pop-Location
    }
}

if ($Clean) {
    Write-Host "Cleaning build and output directories..."
    Remove-Item $buildDir -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item $outputDir -Recurse -Force -ErrorAction SilentlyContinue
}

New-Item -ItemType Directory -Path $buildDir -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Test-Tool -Name "latexmk"
Test-Tool -Name "lualatex"

if ($Mode -eq "notaria" -or $Mode -eq "all" -or $Mode -eq "proyecto_final") {
    Invoke-MermaidRender
}

New-Derivatives

Push-Location $rootDir
try {
    switch ($Mode) {
        "informe" {
            Build-One -FileName "informe.tex"
        }
        "presentacion" {
            Build-One -FileName "presentacion.tex"
        }
        "notaria" {
            Build-One -FileName "notaria.tex"
        }
        "proyecto_final" {
            Build-One -FileName "proyecto_final.tex"
        }
        "all" {
            Build-One -FileName "informe.tex"
            Build-One -FileName "presentacion.tex"
            if (Test-Path (Join-Path $buildDir "notaria.tex")) {
                Build-One -FileName "notaria.tex"
            }
        }
    }

    if (Test-Path (Join-Path $buildDir "informe.pdf")) {
        Copy-Item (Join-Path $buildDir "informe.pdf") (Join-Path $outputDir "informe.pdf") -Force
    }
    if (Test-Path (Join-Path $buildDir "presentacion.pdf")) {
        Copy-Item (Join-Path $buildDir "presentacion.pdf") (Join-Path $outputDir "presentacion.pdf") -Force
    }
    if (Test-Path (Join-Path $buildDir "notaria.pdf")) {
        Copy-Item (Join-Path $buildDir "notaria.pdf") (Join-Path $outputDir "notaria.pdf") -Force
    }
    if (Test-Path (Join-Path $buildDir "proyecto_final.pdf")) {
        Copy-Item (Join-Path $buildDir "proyecto_final.pdf") (Join-Path $outputDir "proyecto_final.pdf") -Force
    }

    Write-Host "Done. Generated PDFs are in IAparaBD/output/."
}
finally {
    Pop-Location
}