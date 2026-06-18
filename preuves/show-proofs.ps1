$host.UI.RawUI.WindowTitle = "TP Data Lake - Preuves"
Write-Host ""
Write-Host "=========================================================" -ForegroundColor Cyan
Write-Host "   TP DATA LAKE - PREUVES (MinIO + PostgreSQL + n8n)" -ForegroundColor Cyan
Write-Host "=========================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host ">>> [A] CONTENEURS DOCKER" -ForegroundColor Yellow
docker compose -f C:\Users\Admin\Desktop\tp-datalake\docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
Write-Host ">>> [A] BUCKETS MinIO + OBJETS STOCKES" -ForegroundColor Yellow
docker run --rm --network tp-datalake_default --entrypoint /bin/sh minio/mc:latest -c "mc alias set local http://minio:9000 minioadmin minioadmin123 >/dev/null && echo '--- Buckets ---' && mc ls local && echo '' && echo '--- Objets (recursif) ---' && mc ls --recursive local"

Write-Host ""
Write-Host ">>> [B] TABLES POSTGRESQL" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "\dt"

Write-Host ""
Write-Host ">>> [B] STRUCTURE DE LA TABLE pokemon_files" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "\d pokemon_files"

Write-Host ""
Write-Host ">>> [C] METADONNEES ENREGISTREES (pokemon_files)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT file_id, pokemon_id, bucket_name, object_key, file_type, mime_type, file_size FROM pokemon_files;"

Write-Host ""
Write-Host ">>> [C] JOURNAL D'INGESTION (file_ingestion_log)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT log_id, file_name, bucket_name, source, status FROM file_ingestion_log;"

Write-Host ""
Write-Host ">>> [C] JOINTURE pokemon <-> fichiers (la base relie tout)" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "SELECT p.name, f.bucket_name, f.object_key, f.file_type FROM pokemon p JOIN pokemon_files f ON f.pokemon_id = p.pokemon_id ORDER BY f.file_id;"

Write-Host ""
Write-Host "=========================================================" -ForegroundColor Green
Write-Host "   FIN DES PREUVES" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green
