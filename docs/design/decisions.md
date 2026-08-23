# Journal des décisions de design

Décisions produit / design tranchées, avec le **pourquoi** (pas juste le résultat).
Une entrée par décision.

## D1 — Bouton central « Votre QR » (bottom nav)

- **Date** : 2026-08-21
- **Décision** : **Ajouter** un bouton central « Votre QR » à la bottom nav, avec
  **bascule automatique selon le contexte** (Option A) : il affiche le **QR de la
  commande active** (statut `AWAITING_PAYMENT` → `READY`) s'il en existe une,
  **sinon le Food Pass**.
- **Statut vis-à-vis du gelé** : **dérogation validée par le PO** à la nav gelée à
  5 onglets (`CLAUDE.md`). La nav devient donc **5 onglets + 1 action centrale QR**.
- **Pourquoi** : parcours le plus fluide (1 tap, « le bon QR au bon moment ») et
  conforme aux maquettes Figma. Option retenue malgré la logique implicite, le PO
  privilégiant la rapidité d'usage au comptoir.
- **Garde-fous à respecter à l'implémentation** (issus de l'analyse des options) :
  - Prévoir une **bascule manuelle de repli** vers l'autre QR, pour le cas « les
    deux sont pertinents » (commande en cours mais on veut montrer le Food Pass).
  - Définir « commande active » de façon fiable : **autorité serveur** ; en mock,
    prendre la **commande non terminale la plus récente**. Multi-commandes actives
    (max 3) → la plus récente non terminale.
  - Ne pas casser les accès existants : Food Pass via Cantine/Profil, QR commande
    via Commandes → suivi.
- **Impact / planning** : l'implémentation (nav + écran QR contextuel) n'est pas
  dans les points 3–11 du plan de polish en cours ; à planifier séparément.

## D2 — Identité du logo sur l'écran Login

- **Date** : 2026-08-21
- **Décision** : l'écran Login porte l'**identité produit SUP2I FOOD** — on garde
  l'**emblème app-icon** actuel (`assets/images/sup2i_logo.png`). Pas de logo
  institutionnel « Sup2i (école) » sur cet écran.
- **Pourquoi** : l'app EST le produit de restauration ; cohérence avec l'icône
  d'application et le branding produit (reconnaissance immédiate).
- **État du code** : **déjà conforme** — l'emblème produit est affiché ; aucun
  changement de code requis pour cette décision.
- **Sous-point mineur en attente** : la tagline actuelle « Reconnu par l'État »
  est **institutionnelle**. Sur une identité produit, à confirmer : la **garder**
  (co-mention école), la **retirer**, ou la **remplacer** par la signature
  produit de la charte « La restauration étudiante, simple et intelligente ».

## D3 — Écran plein écran « commande prête »

- **Date** : 2026-08-22
- **Décision** : au **passage effectif** d'une commande au statut **READY**, on
  pousse un **écran dédié plein écran** (`OrderReadyPage`, route `fullscreenDialog`)
  sur fond `success`, centré sur le **QR de retrait** (200 px), le titre « Votre
  commande est prête ! » et le **numéro** en grand.
- **Déclenchement** : détecté côté suivi (`OrderTrackingPage`) sur la **transition**
  de statut (précédent ≠ READY → READY). Le **premier rendu n'ouvre jamais** le
  plein écran, même si la commande est déjà prête : ouvrir le suivi est un choix
  de l'utilisateur.
- **Repli manuel** : sur le suivi, le **bandeau « prêt » est tapable** et rouvre
  l'écran plein écran à tout moment.
- **Pourquoi** : moment clé du parcours (aller au comptoir) → besoin d'un écran
  très lisible et impossible à manquer, distinct du suivi dense. Ne pas détourner
  au 1er rendu évite de « voler » la navigation quand on consulte une commande.
- **Charte / à venir** : l'animation de **pulsation (250–400 ms)** sur cet écran
  est traitée au **point 7** (durées d'animation + `prefers-reduced-motion`).

## D4 — Skeleton screens plutôt que spinner (Catalogue + Détail)

- **Date** : 2026-08-22
- **Décision** : sur le **Catalogue** (grille) et le **Détail produit**, l'état de
  chargement affiche un **squelette** reproduisant la mise en page réelle
  (`CatalogueSkeleton`, `ProductDetailSkeleton`) au lieu du spinner générique
  (`AppLoadingView`). Primitive partagée `Skeleton` (pulsation d'opacité ~1 s).
- **Pourquoi** : perception de rapidité et **absence de saut visuel** (le contenu
  réel prend la même place que le squelette) ; meilleure lisibilité de ce qui
  arrive. Le spinner reste utilisé sur les écrans sans mise en page riche.
- **Accessibilité** : respecte `prefers-reduced-motion`
  (`MediaQuery.disableAnimations`) → squelette **statique** si l'utilisateur a
  réduit les animations. Aligné avec le **point 7** (charte des durées).

## D5 — Charte d'animation (durées, courbes, reduced-motion)

- **Date** : 2026-08-22
- **Décision** : centraliser les durées/courbes dans `AppMotion`
  (`lib/core/theme/app_motion.dart`), source de vérité :
  - **UI courante** : 160–220 ms (`ui` 200 ms, `uiFast` 160 ms), courbe
    `easeInOut`.
  - **Pulsation « commande prête »** : 250–400 ms (`pulse` 320 ms), **bornée à
    3 cycles** puis repos (n'accapare pas l'attention, ne bloque pas les tests).
  - **Micro-scale ajout panier** : 160–200 ms (`cartAdd` 180 ms), courbe
    `easeOutBack` (léger rebond) — badge du `CartButton` à chaque ajout.
- **`prefers-reduced-motion`** : toute animation passe par
  `AppMotion.reduceMotion(context)` / `effective(context, d)` (0 ms si réduit).
  Appliqué au check de `OrderReadyPage`, au badge `CartButton` et au `Skeleton`.
- **Pourquoi** : cohérence perçue, feedbacks brefs et non intrusifs, et
  accessibilité (respect du réglage système). Valeurs en dur proscrites.

## D6 — Golden tests : périmètre et contraintes

- **Date** : 2026-08-22
- **Décision** : golden tests sur 5 écrans clés — Accueil, Catalogue, Panier,
  Commande QR (suivi), Food Pass (`test/golden/`, images dans
  `test/golden/goldens/`).
- **Contraintes de rendu** :
  - `google_fonts` récupère les polices par réseau ; en test il n'y a pas de
    réseau. `test/flutter_test_config.dart` désactive la récupération runtime
    (`allowRuntimeFetching = false`) et ignore l'erreur d'absence de police
    (retombée sur la police par défaut du harnais). Rendu ainsi déterministe.
  - La police de repli étant plus large que Montserrat/Inter, les goldens sont
    rendus sur un gabarit généreux (**440×956**) pour éviter des débordements
    propres au test (aucun débordement dans l'app réelle avec les vraies
    polices).
  - Le rendu dépend de la plateforme : goldens **générés/vérifiés en local
    (Windows)** et **exclus de la CI Linux** (`flutter test --exclude-tags
    golden`, tag déclaré dans `dart_test.yaml`) pour éviter les faux négatifs.
- **Régénération** : `flutter test --update-goldens --tags golden`.
- **Pourquoi** : filet anti-régression visuelle sur les écrans critiques, sans
  fragiliser la CI ni dépendre du réseau.

## D7 — Passe accessibilité (Panier, Commande QR, Food Pass)

- **Date** : 2026-08-23
- **Décision** : rendre les écrans clés utilisables au lecteur d'écran et au
  tactile :
  - **QR annoncés** : chaque QR (suivi commande, écran commande prête, Food
    Pass) est enveloppé dans `Semantics(image: true, label: …)` avec
    `ExcludeSemantics` sur les modules — le lecteur annonce « Code QR de retrait
    de la commande A1949 » / « Code QR du Food Pass » au lieu du bruit des
    modules.
  - **Panier** : nom + options + prix d'une ligne regroupés (`MergeSemantics`)
    en une annonce ; boutons +/- dotés de **tooltips** (`Augmenter/Diminuer la
    quantité`) ; la quantité expose un `semanticsLabel` « Quantité : N ».
  - **Cibles tactiles** : les actions passent par `IconButton`/boutons Material
    (zone tactile ≥ 48 dp, `MaterialTapTargetSize.padded`), au-delà du minimum
    44×44.
  - **Contrastes / couleur seule** : les statuts (commande, Food Pass) restent
    toujours accompagnés d'un **libellé texte** (jamais la couleur seule).
- **l10n** : labels d'accessibilité en FR/AR/EN.
- **Pourquoi** : conformité aux bonnes pratiques mobiles (WCAG/▸ lecteur
  d'écran), parcours critiques (retrait au comptoir) accessibles.


## D8 — Icônes de catégories (Phosphor) et couleur d'état

- **Date** : 2026-08-23
- **Décision** : les chips de catégories (Catalogue/Accueil) portent une **icône
  Phosphor** (`phosphor_flutter`, licence MIT) : Tacos→hamburger, Pizza→pizza,
  Pasticio→bowlFood, Boisson→coffee, Dessert→iceCream, « Tous »/inconnu→forkKnife
  (`categoryIcon`, mapping décoratif avec repli).
- **Couleur = état UI, pas la catégorie** (charte §22) : icône + libellé
  **pink600** quand actif, **muted** (icône) quand inactif ; **jamais** une
  couleur différente par sous-marque/catégorie.
- **Changement visuel** : le chip sélectionné passe d'un **aplat pink600 plein**
  à un **fond teinté pink600 (12%) + icône/texte pink600** (bordure pink600).
  Motivé par la consigne « icône pink600 à l'état actif » : sur un aplat plein,
  l'icône pink serait invisible. Contraste texte pink600 sur teinte claire OK.
- **Impact tests** : goldens `catalogue`/`home` régénérés (changement voulu).
- **Pourquoi** : repères visuels rapides par catégorie tout en gardant une
  sémantique de couleur cohérente (état, pas identité de sous-marque).
