# Sélection de créneau — Snack (M4)

> Référence : `references/selection-creneau.png` · Conventions : [README.md](README.md)

## Rôle
Choix d'un créneau de retrait horaire pour la commande.

## Composants
- Titre « Choisir un créneau » + date du jour (`Aujourd'hui — mardi 19 août`).
- Liste de créneaux, chacun : plage horaire + **badge d'état** + radio de sélection.
- États de créneau : **Disponible** (`success`), **Sélectionné** (encadré `pink600`, radio plein), **Presque complet** (`warning`), **Complet** (`error`/`muted`, désactivé).

## Tokens appliqués
- Badge Disponible : `success` `#22C55E` ; Presque complet : `warning` `#F59E0B` ; Complet : `error`/`muted`.
- Créneau sélectionné : bordure `pink600`, fond `pink500` clair.
- Horaires : `bodyM` `neutral900` ; badges : `caption` + libellé texte.

## Règles métier
- Créneaux, capacités et états **serveur** — jamais de slots/quotas en dur, jamais recalculés.
- **État jamais signalé par couleur seule** : badge + libellé (« Disponible », « Complet »…).
- Créneau « Complet » non sélectionnable ; tentative → `SLOT_FULL`. Fermé → `SLOT_CLOSED`.
- Sélection reportée au panier ; confirmation crée/maj la commande.

## ⚠️ Divergences
- Orthographe « creneau / Ajourd'hui » → « créneau / Aujourd'hui ».

## Plus tard
M4 : sélection créneau reliée au panier + écran « créneau complet ».
