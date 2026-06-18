const fs = require("fs");
const path = require("path");
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell, ImageRun,
  AlignmentType, HeadingLevel, BorderStyle, WidthType, ShadingType, PageBreak, VerticalAlign
} = require("docx");

const P = "C:\\Users\\Admin\\Desktop\\tp-datalake\\preuves";

// --- lecture dimensions PNG (IHDR) ---
function pngSize(file) {
  const b = fs.readFileSync(file);
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20) };
}
function img(file, maxW) {
  const { w, h } = pngSize(file);
  const width = Math.min(maxW, w);
  const height = Math.round(h * (width / w));
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { before: 120, after: 80 },
    children: [new ImageRun({
      type: "png",
      data: fs.readFileSync(file),
      transformation: { width, height },
      altText: { title: file, description: file, name: path.basename(file) },
    })],
  });
}
function caption(t) {
  return new Paragraph({
    alignment: AlignmentType.CENTER,
    spacing: { after: 200 },
    children: [new TextRun({ text: t, italics: true, size: 18, color: "666666" })],
  });
}
function h1(t) { return new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun(t)] }); }
function h2(t) { return new Paragraph({ heading: HeadingLevel.HEADING_2, children: [new TextRun(t)] }); }
function p(runs) {
  if (typeof runs === "string") runs = [new TextRun(runs)];
  return new Paragraph({ spacing: { after: 120 }, children: runs });
}
function bullet(t) {
  return new Paragraph({ numbering: { reference: "bul", level: 0 }, spacing: { after: 40 }, children: [new TextRun(t)] });
}
function code(lines) {
  return new Paragraph({
    spacing: { before: 60, after: 120 },
    shading: { fill: "1E1E1E", type: ShadingType.CLEAR },
    border: { left: { style: BorderStyle.SINGLE, size: 18, color: "4472C4", space: 6 } },
    children: lines.flatMap((ln, i) => {
      const r = new TextRun({ text: ln, font: "Consolas", size: 18, color: "D4D4D4" });
      return i === 0 ? [r] : [new TextRun({ break: 1, text: ln, font: "Consolas", size: 18, color: "D4D4D4" })];
    }),
  });
}

const border = { style: BorderStyle.SINGLE, size: 1, color: "BFBFBF" };
const borders = { top: border, bottom: border, left: border, right: border };
function cell(text, w, opts = {}) {
  return new TableCell({
    borders, width: { size: w, type: WidthType.DXA },
    shading: { fill: opts.fill || "FFFFFF", type: ShadingType.CLEAR },
    margins: { top: 60, bottom: 60, left: 100, right: 100 },
    verticalAlign: VerticalAlign.CENTER,
    children: [new Paragraph({ children: [new TextRun({ text, bold: !!opts.bold, size: 19 })] })],
  });
}

const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 22 } } },
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 30, bold: true, font: "Arial", color: "1F3864" },
        paragraph: { spacing: { before: 280, after: 160 }, outlineLevel: 0,
          border: { bottom: { style: BorderStyle.SINGLE, size: 6, color: "4472C4", space: 4 } } } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal", quickFormat: true,
        run: { size: 25, bold: true, font: "Arial", color: "2E5496" },
        paragraph: { spacing: { before: 200, after: 100 }, outlineLevel: 1 } },
    ],
  },
  numbering: {
    config: [{ reference: "bul", levels: [{ level: 0, format: "bullet", text: "•", alignment: AlignmentType.LEFT,
      style: { paragraph: { indent: { left: 600, hanging: 280 } } } }] }],
  },
  sections: [{
    properties: { page: { size: { width: 12240, height: 15840 }, margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 } } },
    children: [
      // ----- Page de titre -----
      new Paragraph({ spacing: { before: 1800, after: 0 }, alignment: AlignmentType.CENTER,
        children: [new TextRun({ text: "TP — Data Lake", bold: true, size: 64, color: "1F3864", font: "Arial" })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 120, after: 0 },
        children: [new TextRun({ text: "Du modèle relationnel vers une architecture Data Lake / Lakehouse", size: 26, color: "2E5496" })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 240, after: 0 },
        children: [new TextRun({ text: "MinIO  ·  PostgreSQL  ·  n8n  ·  Docker", size: 24, italics: true, color: "666666" })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 1200, after: 0 },
        children: [new TextRun({ text: "Nom : Khalil Jaouani", size: 24, bold: true })] }),
      new Paragraph({ alignment: AlignmentType.CENTER, spacing: { before: 80 },
        children: [new TextRun({ text: "Date : 18 juin 2026", size: 24 })] }),
      new Paragraph({ children: [new PageBreak()] }),

      // ----- Introduction -----
      h1("Introduction & architecture"),
      p("L’objectif de ce TP est de faire évoluer l’architecture relationnelle du matin (PostgreSQL alimenté depuis la PokéAPI via n8n) vers une véritable architecture Data Lake / Lakehouse, en ajoutant une couche de stockage objet avec MinIO."),
      p("Le principe : MinIO conserve les fichiers bruts (réponses JSON de l’API, images, rapports), tandis que PostgreSQL ne stocke plus le fichier lui-même mais joue le rôle de catalogue : il garde les métadonnées et un pointeur (bucket + clé objet) vers chaque fichier, et relie chaque fichier à un Pokémon."),
      p([new TextRun({ text: "Composants déployés (un seul docker-compose) :", bold: true })]),
      bullet("PostgreSQL — base « catalogue » (métadonnées + liens vers MinIO)"),
      bullet("MinIO — stockage objet S3 (le « lac » : fichiers bruts)"),
      bullet("n8n — orchestrateur du workflow d’ingestion"),
      bullet("Flux : n8n récupère un Pokémon via la PokéAPI → dépose les fichiers dans MinIO → enregistre les métadonnées dans PostgreSQL"),

      // ----- Partie A -----
      h1("Partie A — Stockage objet avec MinIO"),
      p("MinIO a été ajouté à l’environnement Docker (image officielle minio/minio), exposé sur le port 9000 (API S3) et 9001 (console web). Le service démarre correctement (état « healthy »)."),
      p([new TextRun({ text: "Organisation de stockage retenue : 3 buckets distincts", bold: true }),
         new TextRun(", choix justifié par la séparation claire des natures de données :")]),
      bullet("raw-pokemon — données brutes (réponses JSON de la PokéAPI)"),
      bullet("pokemon-images — images officielles / sprites"),
      bullet("reports — rapports (CSV/JSON) et fichiers d’anomalies"),
      p("Cette séparation par bucket rend l’organisation lisible et permet d’appliquer des politiques différentes par type de donnée."),
      img(path.join(P, "01_infra_docker_minio_buckets.png"), 600),
      caption("Preuve A — Conteneurs Docker (MinIO/PostgreSQL/n8n), buckets MinIO, objets réellement stockés et tables PostgreSQL."),

      // ----- Partie B -----
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_1, children: [new TextRun("Partie B — Base enrichie")] }),
      p("Deux tables principales ont été créées, en plus d’une table pokemon (pour relier un fichier à un Pokémon)."),
      h2("Table pokemon_files (catalogue des fichiers)"),
      code([
        "CREATE TABLE pokemon_files (",
        "  file_id      BIGSERIAL PRIMARY KEY,",
        "  pokemon_id   INTEGER REFERENCES pokemon(pokemon_id),",
        "  bucket_name  VARCHAR(100) NOT NULL,   -- ex: raw-pokemon",
        "  object_key   VARCHAR(500) NOT NULL,   -- ex: pikachu/raw.json",
        "  file_name    VARCHAR(255) NOT NULL,",
        "  file_type    VARCHAR(50),             -- raw_json | image | report",
        "  mime_type    VARCHAR(100),            -- enrichissement",
        "  file_size    BIGINT,                  -- enrichissement",
        "  internal_url VARCHAR(500),            -- enrichissement",
        "  checksum     VARCHAR(128),            -- enrichissement",
        "  created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),",
        "  UNIQUE (bucket_name, object_key)",
        ");",
      ]),
      h2("Table file_ingestion_log (journal des traitements)"),
      code([
        "CREATE TABLE file_ingestion_log (",
        "  log_id       BIGSERIAL PRIMARY KEY,",
        "  file_name    VARCHAR(255),",
        "  bucket_name  VARCHAR(100),",
        "  object_key   VARCHAR(500),",
        "  source       VARCHAR(100),   -- ex: pokeapi",
        "  status       VARCHAR(30),    -- SUCCESS | ERROR | SKIPPED",
        "  message      TEXT,",
        "  processed_at TIMESTAMPTZ NOT NULL DEFAULT now()",
        ");",
      ]),
      p("La table pokemon_files trace, pour chaque fichier : le bucket, la clé objet, le nom, le type, ainsi que des colonnes d’enrichissement (type MIME, taille, URL interne, checksum). La table file_ingestion_log trace chaque traitement (nom de fichier, bucket, clé, source, date, statut)."),

      // ----- Partie C -----
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_1, children: [new TextRun("Partie C — Workflow n8n")] }),
      p("Un workflow n8n (« TP Data Lake - Ingestion Pokemon ») réalise la chaîne complète d’ingestion. Il enchaîne 9 nœuds :"),
      bullet("Demarrer — déclencheur manuel"),
      bullet("PokeAPI - Get Pokemon — appel HTTP GET vers la PokéAPI"),
      bullet("Preparer metadonnees — extraction des champs + construction des clés objets"),
      bullet("MinIO - Upload JSON brut — dépôt de la réponse brute dans raw-pokemon (HTTP PUT)"),
      bullet("PokeAPI - Get Image — téléchargement de l’image officielle"),
      bullet("MinIO - Upload Image — dépôt de l’image dans pokemon-images"),
      bullet("PG - Upsert Pokemon — insertion/MAJ du Pokémon dans PostgreSQL"),
      bullet("PG - Inserer fichiers — enregistrement des métadonnées dans pokemon_files"),
      bullet("PG - Journal ingestion — écriture du statut dans file_ingestion_log"),
      img(path.join(P, "04_n8n_workflow_execute.png"), 620),
      caption("Preuve C.1 — Workflow n8n exécuté avec succès : tous les nœuds sont validés (coches vertes, « 1 item »)."),
      img(path.join(P, "02_metadonnees_postgresql.png"), 600),
      caption("Preuve C.2 — Métadonnées enregistrées dans PostgreSQL (pokemon_files, file_ingestion_log) et jointure pokemon ↔ fichiers."),
      h2("Exemple d’objet stocké dans MinIO"),
      p("Exemple : l’image officielle de Pikachu, déposée par le workflow et servie directement depuis MinIO."),
      img(path.join(P, "05_minio_image_pikachu.png"), 260),
      caption("Preuve C.3 — Objet stocké : http://localhost:9000/pokemon-images/pikachu/official-artwork.png"),

      // ----- Partie D -----
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_1, children: [new TextRun("Partie D — Réponse rédigée")] }),
      p([new TextRun({ text: "Pourquoi cette architecture est plus proche d’une logique Data Lake / Lakehouse ?", bold: true })]),
      p("L’architecture du matin reposait uniquement sur une base relationnelle (PostgreSQL), où toute la donnée devait être structurée en colonnes avant d’être stockée. En ajoutant MinIO, on introduit une véritable couche de stockage objet complémentaire à la base : les fichiers bruts (JSON de la PokéAPI, images, rapports) sont conservés tels quels, sans transformation préalable."),
      p("Conserver le brut est utile car on garde la donnée d’origine intacte : on peut la re-traiter plus tard, l’auditer, ou en extraire de nouvelles informations sans rappeler l’API. Point clé : la base ne contient plus le fichier lui-même, mais seulement ses métadonnées et un pointeur (bucket + clé objet) vers MinIO ; PostgreSQL devient un catalogue qui relie chaque fichier à un Pokémon."),
      p("Cette séparation rend l’architecture plus riche qu’une simple base relationnelle : elle gère à la fois des données structurées (tables) et non structurées (images, JSON brut), elle passe mieux à l’échelle (le stockage objet est conçu pour de gros volumes et de gros fichiers) et elle découple le stockage du calcul. On retrouve ainsi les principes d’un Data Lake (stockage brut, multi-formats, peu coûteux) couplé à un catalogue interrogeable en SQL, soit la logique d’un Lakehouse."),

      // ----- Livrables -----
      new Paragraph({ pageBreakBefore: true, heading: HeadingLevel.HEADING_1, children: [new TextRun("Récapitulatif des livrables")] }),
      new Table({
        width: { size: 9360, type: WidthType.DXA }, columnWidths: [5400, 3960],
        rows: [
          new TableRow({ tableHeader: true, children: [cell("Livrable attendu", 5400, { bold: true, fill: "1F3864" }), cell("Où dans ce document", 3960, { bold: true, fill: "1F3864" })] }),
          new TableRow({ children: [cell("Ajout de MinIO dans Docker", 5400), cell("Partie A — Preuve A", 3960)] }),
          new TableRow({ children: [cell("Création des buckets / organisation", 5400), cell("Partie A — Preuve A", 3960)] }),
          new TableRow({ children: [cell("Structure SQL ajoutée", 5400), cell("Partie B (CREATE TABLE)", 3960)] }),
          new TableRow({ children: [cell("Workflow n8n (capture)", 5400), cell("Partie C — Preuve C.1", 3960)] }),
          new TableRow({ children: [cell("Exemple d’objet stocké dans MinIO", 5400), cell("Partie C — Preuve C.3", 3960)] }),
          new TableRow({ children: [cell("Enregistrement des métadonnées en base", 5400), cell("Partie C — Preuve C.2", 3960)] }),
          new TableRow({ children: [cell("Réponse rédigée", 5400), cell("Partie D", 3960)] }),
        ],
      }),
      new Paragraph({ spacing: { before: 240 }, children: [new TextRun({ text: "Accès aux services (environnement local)", bold: true, size: 22 })] }),
      bullet("Console MinIO : http://localhost:9001  (minioadmin / minioadmin123)"),
      bullet("n8n : http://localhost:5678  (admin@datalake.local / Datalake2026)"),
      bullet("PostgreSQL : localhost:5432  (pokeuser / pokepass, base pokedex)"),
    ],
  }],
});

Packer.toBuffer(doc).then(buf => {
  const out = "C:\\Users\\Admin\\Desktop\\tp-datalake\\TP_Data_Lake_Compte_Rendu.docx";
  fs.writeFileSync(out, buf);
  console.log("DOCX cree -> " + out + " (" + buf.length + " octets)");
});
