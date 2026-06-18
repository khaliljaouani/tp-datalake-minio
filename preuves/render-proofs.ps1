Add-Type -AssemblyName System.Drawing

function New-ProofImage {
  param([string[]]$Lines, [string]$Out)
  $font   = New-Object System.Drawing.Font("Consolas", 13)
  $fontB  = New-Object System.Drawing.Font("Consolas", 14, [System.Drawing.FontStyle]::Bold)
  $padX = 24; $padY = 20; $lh = 22
  $width = 1180
  $height = $padY*2 + ($Lines.Count * $lh)
  $bmp = New-Object System.Drawing.Bitmap($width, $height)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = 'AntiAlias'
  $g.TextRenderingHint = 'ClearTypeGridFit'
  $g.Clear([System.Drawing.Color]::FromArgb(12,12,12))
  $colText  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(220,220,220))
  $colHead  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255,214,10))
  $colCyan  = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(97,214,214))
  $colGreen = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(95,215,95))
  $y = $padY
  foreach ($ln in $Lines) {
    $brush = $colText; $f = $font
    if     ($ln -match '^==')   { $brush = $colCyan;  $f = $fontB }
    elseif ($ln -match '^>>>')  { $brush = $colHead;  $f = $fontB }
    elseif ($ln -match '^\+\+') { $brush = $colGreen; $f = $fontB; $ln = $ln.Substring(2) }
    $g.DrawString($ln, $f, $brush, $padX, $y)
    $y += $lh
  }
  $g.Dispose(); $bmp.Save($Out); $bmp.Dispose()
  Write-Host "OK -> $Out"
}

$cs = "C:\Users\Admin\Desktop\tp-datalake\docker-compose.yml"

# ---------- PREUVE A : infra ----------
$A = @()
$A += "== TP DATA LAKE - PREUVE A : MinIO dans Docker + Buckets + Objets =="
$A += ""
$A += ">>> Conteneurs Docker (docker compose ps)"
$A += (docker compose -f $cs ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" | Out-String).TrimEnd().Split("`n")
$A += ""
$A += ">>> Buckets MinIO + objets stockes (mc ls --recursive)"
$A += (docker run --rm --network tp-datalake_default --entrypoint /bin/sh minio/mc:latest -c "mc alias set local http://minio:9000 minioadmin minioadmin123 >/dev/null && echo '--- Buckets ---' && mc ls local && echo '--- Objets stockes ---' && mc ls --recursive local" | Out-String).TrimEnd().Split("`n")
$A += ""
$A += ">>> Tables PostgreSQL (\dt)"
$A += (docker exec datalake-postgres psql -U pokeuser -d pokedex -c "\dt" | Out-String).TrimEnd().Split("`n")
$A += ""
$A += "++FIN PREUVE A"
New-ProofImage -Lines $A -Out "C:\Users\Admin\Desktop\tp-datalake\preuves\01_infra_docker_minio_buckets.png"

# ---------- PREUVE B/C : donnees ----------
$B = @()
$B += "== TP DATA LAKE - PREUVE B/C : Metadonnees enregistrees en base =="
$B += ""
$B += ">>> Table pokemon_files (catalogue : ou est chaque fichier dans MinIO)"
$B += (docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT file_id, pokemon_id, bucket_name, object_key, file_type, mime_type FROM pokemon_files;" | Out-String).TrimEnd().Split("`n")
$B += ""
$B += ">>> Table file_ingestion_log (journal des traitements)"
$B += (docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT log_id, file_name, bucket_name, source, status FROM file_ingestion_log;" | Out-String).TrimEnd().Split("`n")
$B += ""
$B += ">>> Jointure pokemon <-> fichiers (la base relie le tout)"
$B += (docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT p.name AS pokemon, f.bucket_name, f.object_key, f.file_type FROM pokemon p JOIN pokemon_files f ON f.pokemon_id = p.pokemon_id ORDER BY f.file_id;" | Out-String).TrimEnd().Split("`n")
$B += ""
$B += "++FIN PREUVE B/C"
New-ProofImage -Lines $B -Out "C:\Users\Admin\Desktop\tp-datalake\preuves\02_metadonnees_postgresql.png"
