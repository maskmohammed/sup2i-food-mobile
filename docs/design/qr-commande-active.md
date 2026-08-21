# QR de commande active — Snack (M6)

> Référence : `references/qr-commande-active.png` · Conventions : [README.md](README.md)

## Rôle
Suivi d'une commande en cours : **QR de retrait** + **badge d'état** + **timeline** de progression + récap articles. Écran vivant qui suit la state machine.

## Composants
- QR de la commande (cadre à coins).
- **Badge d'état** courant (pill) : ex. « En préparation ».
- **Timeline verticale** à 4 étapes, chacune = pastille + libellé texte :
  1. **Paiement confirmé** — fait (`success`)
  2. **Commande reçue** — fait (`success`)
  3. **En préparation** — étape courante (`pink600`)
  4. **Votre commande est prête** — à venir (`muted`/blanc)
- Séparateur + récap : « 2 articles », `Tacos Poulet XL x1`, `Pizza margherita x2`.

## Tokens appliqués
- Étape faite : pastille `success` `#22C55E` + libellé `neutral900`.
- Étape courante : pastille `pink600` + libellé `neutral900` (gras).
- Étape à venir : pastille blanche/`border` + libellé `muted`.
- Badge état : pill, `label` ; récap articles : `bodyM`/`caption`.

## Règles métier
- Étapes = state machine : **PAID → QUEUED (« reçue ») → PREPARING → READY**.
- **Cohérence badge ↔ timeline obligatoire** : le badge courant doit toujours correspondre à l'étape active (correction validée — ne pas régresser).
- **Statut jamais par couleur seule** : chaque étape porte un libellé texte.
- État **piloté serveur** (le Mobile ne fait pas avancer la commande localement).
- Une commande `AWAITING_PAYMENT` n'est **jamais** en préparation.
- Passage à READY → écran [commande prête](commande-prete.md).

## ⚠️ Divergences
- « Paiement confirmé / Commande Reçue » : garder libellés cohérents et accentués.
- Bouton central « Votre QR » : **décision produit ouverte** — cet écran (QR commande active) vs [Food Pass](food-pass.md) selon le contexte. À arbitrer avant de coder la nav.

## Plus tard
M6 : écran de suivi + timeline ; M7 : rafraîchissement temps réel (push).
