$host.UI.RawUI.WindowTitle = "PREUVE-B-DATA"
Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  TP DATA LAKE - PREUVE B/C : Metadonnees enregistrees en base" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ">>> Table pokemon_files (catalogue : ou est chaque fichier)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT file_id, pokemon_id, bucket_name, object_key, file_type, mime_type FROM pokemon_files;"
Write-Host ""
Write-Host ">>> Table file_ingestion_log (journal des traitements)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT log_id, file_name, bucket_name, source, status FROM file_ingestion_log;"
Write-Host ""
Write-Host ">>> Jointure pokemon <-> fichiers (la base relie le tout)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT p.name AS pokemon, f.bucket_name, f.object_key, f.file_type FROM pokemon p JOIN pokemon_files f ON f.pokemon_id = p.pokemon_id ORDER BY f.file_id;"
Write-Host ""
Write-Host "================== FIN PREUVE B/C ==================" -ForegroundColor Green
Start-Sleep -Seconds 600
