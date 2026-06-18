# Partie D — Réponse rédigée

**Pourquoi l'architecture obtenue est plus proche d'une logique Data Lake / Lakehouse que celle du matin**

L'architecture du matin reposait uniquement sur une base relationnelle (PostgreSQL),
où toute la donnée devait être structurée en colonnes avant d'être stockée. En ajoutant
MinIO, on introduit une véritable couche de **stockage objet** complémentaire à la base :
les fichiers bruts (réponse JSON de la PokéAPI, images officielles, rapports) sont
désormais conservés tels quels, sans transformation préalable. **Conserver le brut** est
utile car on garde la donnée d'origine intacte : on peut la re-traiter plus tard, l'auditer,
ou en extraire de nouvelles informations sans avoir à rappeler l'API. Point clé : **la base
ne contient plus le fichier lui-même**, mais seulement ses **métadonnées** et un **pointeur**
(bucket + clé objet) vers MinIO ; PostgreSQL joue le rôle de **catalogue** qui relie chaque
fichier à un Pokémon. Cette séparation rend l'architecture **plus riche** qu'une simple base
relationnelle : elle gère aussi bien des données structurées (tables) que des données non
structurées (images, JSON brut), elle passe mieux à l'échelle (le stockage objet est conçu
pour de gros volumes et de gros fichiers), et elle découple le stockage du calcul. On retrouve
ainsi les principes d'un **Data Lake** (stockage brut, multi-formats, peu coûteux) couplé à un
**catalogue interrogeable** en SQL — soit exactement la logique d'un **Lakehouse**.
