-- =====================================================================
-- TP Data Lake — Partie B : base enrichie
-- Ce script est exécuté automatiquement au 1er démarrage de PostgreSQL.
-- =====================================================================

-- ---------------------------------------------------------------------
-- Table des Pokémon (pour pouvoir RELIER un fichier à un Pokémon).
-- On garde l'essentiel ici ; la donnée brute complète vit dans MinIO.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pokemon (
    pokemon_id   INTEGER PRIMARY KEY,          -- id officiel de la PokéAPI
    name         VARCHAR(100) NOT NULL,
    height       INTEGER,
    weight       INTEGER,
    base_xp      INTEGER,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Table pokemon_files : le CATALOGUE des fichiers stockés dans MinIO.
-- La base ne contient PAS le fichier, seulement où le trouver + ses infos.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS pokemon_files (
    file_id      BIGSERIAL PRIMARY KEY,
    pokemon_id   INTEGER REFERENCES pokemon(pokemon_id),   -- lien vers le Pokémon
    bucket_name  VARCHAR(100) NOT NULL,                    -- ex: raw-pokemon
    object_key   VARCHAR(500) NOT NULL,                    -- ex: pikachu/raw.json
    file_name    VARCHAR(255) NOT NULL,                    -- ex: raw.json
    file_type    VARCHAR(50),                              -- raw_json | image | report ...
    -- colonnes d'enrichissement (facultatives mais valorisées) :
    mime_type    VARCHAR(100),                             -- ex: application/json
    file_size    BIGINT,                                   -- en octets
    internal_url VARCHAR(500),                             -- URL interne MinIO
    checksum     VARCHAR(128),                             -- hash (md5/sha256)
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (bucket_name, object_key)
);

-- ---------------------------------------------------------------------
-- Table file_ingestion_log : journal de TOUS les traitements d'ingestion
-- (succès comme erreurs). Trace l'historique du pipeline.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS file_ingestion_log (
    log_id       BIGSERIAL PRIMARY KEY,
    file_name    VARCHAR(255),
    bucket_name  VARCHAR(100),
    object_key   VARCHAR(500),
    source       VARCHAR(100),        -- ex: pokeapi, manual, n8n
    status       VARCHAR(30),         -- SUCCESS | ERROR | SKIPPED
    message      TEXT,                -- détail / message d'erreur éventuel
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- ---------------------------------------------------------------------
-- Index utiles
-- ---------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_files_pokemon ON pokemon_files(pokemon_id);
CREATE INDEX IF NOT EXISTS idx_log_status    ON file_ingestion_log(status);
