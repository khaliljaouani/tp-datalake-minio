# TP — Data Lake (MinIO · PostgreSQL · n8n)

Passage d'une architecture relationnelle vers une architecture **Data Lake / Lakehouse** :
MinIO stocke les fichiers bruts (le « lac »), PostgreSQL sert de **catalogue** (métadonnées + pointeurs),
et **n8n** orchestre l'ingestion depuis la PokéAPI.

## 📄 Compte rendu
Le rapport complet à rendre : [`TP_Data_Lake_Compte_Rendu.docx`](TP_Data_Lake_Compte_Rendu.docx)

## 🏗️ Architecture
```
 n8n (workflow)
   1. récupère un Pokémon via la PokéAPI
   2. dépose les fichiers bruts dans MinIO
   3. enregistre les métadonnées dans PostgreSQL
        │                         │
   fichiers bruts            métadonnées + lien
        ▼                         ▼
   MinIO (Data Lake)         PostgreSQL (catalogue)
   raw-pokemon/              pokemon
   pokemon-images/           pokemon_files ──► object_key
   reports/                  file_ingestion_log
```

## 📁 Contenu du dépôt
| Fichier | Description |
|---------|-------------|
| `docker-compose.yml` | Stack Docker : MinIO + PostgreSQL + n8n + création auto des buckets (Partie A) |
| `init-db/01_schema.sql` | Schéma SQL : tables `pokemon`, `pokemon_files`, `file_ingestion_log` (Partie B) |
| `n8n-workflow.json` | Workflow n8n d'ingestion (Partie C) — importable dans n8n |
| `PARTIE-D-reponse.md` | Réponse rédigée (Partie D) |
| `preuves/` | Captures d'écran (preuves) |
| `TP_Data_Lake_Compte_Rendu.docx` | Compte rendu Word complet |

## 🚀 Démarrage
```bash
docker compose up -d
```
- Console MinIO : http://localhost:9001 (`minioadmin` / `minioadmin123`)
- n8n : http://localhost:5678
- PostgreSQL : `localhost:5432` (`pokeuser` / `pokepass`, base `pokedex`)

Importer ensuite `n8n-workflow.json` dans n8n, puis cliquer sur **Execute workflow**.
