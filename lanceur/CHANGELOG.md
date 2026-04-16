## 1.2
- Export chiffré des raccourcis et identifiants (AES-256, PBKDF2, fichier .lncr)
- Import avec choix : remplacer les données existantes ou fusionner (noms en doublon numérotés)
- Nom du fichier d'export modifiable avant partage
- Icônes des raccourcis dans un conteneur arrondi avec fond teinté
- Initiale colorée en fallback quand le favicon est indisponible (couleur dérivée du nom)
- Source des favicons passée à DuckDuckGo (meilleure résolution)
- Vue liste : affichage du domaine à la place de l'URL complète
- Cartes grille plus compactes et mieux proportionnées
- WebView : user-agent Chrome standard (suppression du marqueur WebView Android)
- WebView : gestion des redirections intent:// / market:// (ouverture externe)
- WebView : injection des identifiants limitée au premier chargement
- WebView : bouton "Ouvrir dans le navigateur" dans la barre de navigation
- WebView : page d'erreur avec bouton Réessayer en cas d'échec de chargement
- Réorganisation des raccourcis par glisser-déposer (menu ⋮ → Réorganiser)

## 1.1
- Capture automatique des identifiants saisis manuellement dans la WebView
- Dialog "Sauvegarder les identifiants ?" proposée après soumission d'un formulaire de connexion
- Auto-soumission du formulaire après injection des identifiants enregistrés
- Support des SPA (React, Vue…) via MutationObserver pour les formulaires chargés dynamiquement
- Bouton "À propos" dans la barre de titre avec numéro de version

## 1.0
- Version initiale
- Raccourcis web lancés dans une WebView intégrée
- Stockage sécurisé des mots de passe (flutter_secure_storage)
- Injection automatique des identifiants configurés au chargement de la page
- Vue grille et vue liste commutables
- Favicon des sites affiché dans les tuiles
- Icône cadenas sur les raccourcis associés à des identifiants
- Formulaire d'ajout / modification / suppression de raccourcis
