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
