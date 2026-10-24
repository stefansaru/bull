# doctor.ps1 — Windows wrapper. macOS / Linux twin: ./doctor.sh.
# Both call doctor.py, the single implementation (PROC-REPO-004).
Set-Location -Path $PSScriptRoot
$py = Get-Command py -ErrorAction SilentlyContinue
if ($null -ne $py) { & py -3 doctor.py @args; exit $LASTEXITCODE }
$py = Get-Command python -ErrorAction SilentlyContinue
if ($null -ne $py) { & python doctor.py @args; exit $LASTEXITCODE }
Write-Host "Python 3 not found. Install it with: winget install -e --id Python.Python.3.13" -ForegroundColor Red
exit 1
