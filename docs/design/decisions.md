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

