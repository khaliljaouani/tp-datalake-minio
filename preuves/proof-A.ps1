$host.UI.RawUI.WindowTitle = "PREUVE-A-INFRA"
Write-Host ""
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host "  TP DATA LAKE - PREUVE A : MinIO dans Docker + Buckets + Objets" -ForegroundColor Cyan
Write-Host "===============================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host ">>> Conteneurs Docker du projet (MinIO + PostgreSQL + n8n)" -ForegroundColor Yellow
docker compose -f C:\Users\Admin\Desktop\tp-datalake\docker-compose.yml ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}"
Write-Host ""
Write-Host ">>> Buckets MinIO et objets reellement stockes" -ForegroundColor Yellow
docker run --rm --network tp-datalake_default --entrypoint /bin/sh minio/mc:latest -c "mc alias set local http://minio:9000 minioadmin minioadmin123 >/dev/null && echo '--- Buckets ---' && mc ls local && echo '' && echo '--- Objets stockes (recursif) ---' && mc ls --recursive local"
Write-Host ""
Write-Host ">>> Tables PostgreSQL creees" -ForegroundColor Yellow
docker exec datalake-postgres psql -U pokeuser -d pokedex -c "\dt"
Write-Host ""
Write-Host "================== FIN PREUVE A ==================" -ForegroundColor Green
Start-Sleep -Seconds 600
