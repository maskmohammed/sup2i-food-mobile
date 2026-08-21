# Référence design — SUP2I FOOD Mobile

Documentation écran par écran des maquettes, pour que les sessions futures
(M3 Catalogue, M4 Panier/Créneaux, M6 Orders/QR, M8 Cantine) sachent à quoi
chaque écran doit ressembler sans réexpliquer la charte.

> **Règle de résolution des conflits : le _gelé_ (`CLAUDE.md`) prime sur les maquettes.**
> Les PNG fournis sont une version **antérieure aux corrections d'équipe** : ils
> contiennent des écarts (nav, allergènes, devise, orthographe) signalés dans
> chaque fiche sous « ⚠️ Divergences ». Ces écarts sont **à corriger**, pas à
> reproduire. Voir la synthèse en bas de ce fichier.

Les fichiers ne décrivent **aucun code Dart** : ils cadrent l'UI cible.

## Index des écrans

| Écran | Fiche | Parcours | Jalon |
|-------|-------|----------|-------|
| Login | [login.md](login.md) | Auth | M2 |
| Accueil | [accueil.md](accueil.md) | Snack | M3 |
| Catalogue produits | [catalogue.md](catalogue.md) | Snack | M3 |
| Détail produit + options | [produit-detail.md](produit-detail.md) | Snack | M3–M4 |
| Panier | [panier.md](panier.md) | Snack | M4 |
| Panier vide (état) | [panier-vide.md](panier-vide.md) | Snack | M4 |
| Sélection de créneau | [selection-creneau.md](selection-creneau.md) | Snack | M4 |
| Créneau complet (erreur) | [creneau-complet.md](creneau-complet.md) | Snack | M4 |
| Aucun résultat (recherche) | [aucun-resultat.md](aucun-resultat.md) | Snack | M3 |
| QR de commande active | [qr-commande-active.md](qr-commande-active.md) | Snack | M6 |
| File d'attente (file virtuelle) | [file-attente.md](file-attente.md) | Snack | M7 |
| Commande prête | [commande-prete.md](commande-prete.md) | Snack | M7 |
| Historique commandes | [historique-commandes.md](historique-commandes.md) | Snack | M6 |
| Food Pass (QR) | [food-pass.md](food-pass.md) | Cantine | M8 |
| Perte du Food Pass | [perte-food-pass.md](perte-food-pass.md) | Cantine | M8 |
| Abonnement / quota cantine | [abonnement-cantine.md](abonnement-cantine.md) | Cantine | M8 |
| Menu cantine (semaine) | [cantine-menu.md](cantine-menu.md) | Cantine | M8 |
| Réservation confirmée | [reservation-confirmee.md](reservation-confirmee.md) | Cantine | M8 |
| Favoris | [favoris.md](favoris.md) | Profil | M10 |
| Profil | [profil.md](profil.md) | Profil | M1–M2 |
| Langue (FR/AR/EN) | [langue.md](langue.md) | Profil | M2 |
| Notifications (centre) | [notifications.md](notifications.md) | Transverse | M9 |
| Préférences de notifications | [preferences-notifications.md](preferences-notifications.md) | Transverse | M9 |

> Lot encore incomplet possible : l'utilisateur ajoutera les éventuels écrans
> restants (Splash/Bootstrap, etc.) au fil de l'eau.

## Conventions globales (valables sur tous les écrans)

### Couleurs — `lib/core/theme/app_colors.dart`
| Rôle | Token | Hex |
|------|-------|-----|
| Marque profonde / titres nav actifs | `AppColors.navy900` | `#160F67` |
| Accent CTA principal | `AppColors.pink600` | `#C31A6F` |
| Accent secondaire / liens | `AppColors.blue600` | `#1F25B5` |
| Accent clair (chips, points) | `AppColors.pink500` | `#E6318C` |
| Texte principal | `AppColors.neutral900` | `#252A3A` |
| Fond d'écran | `AppColors.neutral100` | `#F4F5F8` |
| Surfaces / cartes | `AppColors.neutral0` | `#FFFFFF` |
| Texte secondaire / désactivé | `AppColors.muted` | `#8A8D99` |
| Bordures / séparateurs | `AppColors.border` | `#E4E6EE` |
| Succès (READY, payé, retiré) | `AppColors.success` | `#22C55E` |
| Information | `AppColors.info` | `#3B82F6` |
| Alerte (quota faible) | `AppColors.warning` | `#F59E0B` |
| Erreur (annulé, bloqué, perte) | `AppColors.error` | `#EF4444` |

### Typographie — `lib/core/theme/app_typography.dart`
- Titres **Montserrat** : `display` 40/48, `h1` 32/40, `h2` 24/32, `h3` 20/28 (bold).
- Corps **Inter** : `bodyL` 16/24, `bodyM` 14/22, `label` 13/18 (semibold), `caption` 12/16.
- Les titres d'écran roses des maquettes (« Panier », « Historique »…) → `h2`/`h3` en `neutral900` ou `navy900`.

### Composants du kit (charte p.03)
Bouton primaire (plein `pink600`, radius 12), bouton secondaire (outline `border`,
texte `navy900`), champ de saisie (radius 12, bordure `border`, focus `blue600`),
carte produit (surface `neutral0`, radius 12), chip/tag (fond `pink500` clair,
texte foncé), badge/notification (pastille + compteur), bottom nav.
États composants : **Actif** `pink600` · **Désactivé** `muted` · **Survol** `navy900`.

### Règles métier transverses (gelées)
- **Devise** : toujours `35,00 DH` (virgule, 2 décimales, suffixe « DH »). **Jamais** « MAD », « DHS » ni « € ».
- **Statuts jamais signalés par la couleur seule** : toujours un **badge + libellé texte** (`READY`, `PRÉPARATION`, `RETIRÉE`, `ANNULÉE`, `BLOQUÉ`…), pour l'accessibilité.
- **Allergènes produit** : affichés en **chips texte**, jamais uniquement via la photo.
- La feature **« Mes allergènes et restrictions »** (préférences perso étudiant) est **éliminée** — ne jamais la recréer, même si une maquette la montre.
- **Erreurs** gérées sur le champ `code` de l'API, jamais sur `message`.
- Le Mobile **ne confirme jamais un paiement** localement et **ne recalcule pas** prix/stock/quota comme autorité.
- **Bottom nav gelée à 5 onglets** : Accueil / Commander / Cantine / **Commandes** / Profil.

## ⚠️ Synthèse des divergences maquettes ↔ gelé (à corriger)

| Divergence maquette | Règle gelée à appliquer |
|---------------------|-------------------------|
| Nav = `Acceuil / Commander / Votre QR (central) / Contine / Profil` (pas de Commandes) | 5 onglets **Accueil / Commander / Cantine / Commandes / Profil**. Le « Votre QR » central reste une **décision produit ouverte** (cf. SESSION_SUMMARY §4), non gelée. |
| Profil affiche « Mes allergènes et restrictions » | Feature **éliminée** — retirer la ligne. |
| Prix en `MAD` / `DHS` / `€` | Format **`00,00 DH`**. |
| Textes `Acceuil`, `Contine`, `SUPE2I`, `Favories`, `Paiment` | Orthographe correcte : **Accueil, Cantine, SUP2I, Favoris, Paiement**. |
| Food Pass « Bloqué » via badge | ✔ Conforme (badge + libellé, pas couleur seule). À conserver. |
