$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
Push-Location $projectRoot
try {
    flutter build web --base-href /csc_4330_app_5/
    if ($LASTEXITCODE -ne 0) { throw 'Web build failed. Pages files were not updated.' }
    New-Item -ItemType Directory -Path docs -Force | Out-Null
    Get-ChildItem -LiteralPath build/web -Force | Copy-Item -Destination docs -Recurse -Force
    New-Item -ItemType File -Path docs/.nojekyll -Force | Out-Null
    Write-Host 'Pages files are updated. Review, commit, and push docs/ to main.'
} finally {
    Pop-Location
}
