# Menu cantine (semaine) — Cantine (M8)

> Référence : `references/cantine-menu.png` · Conventions : [README.md](README.md)

## Rôle
Menus cantine de la semaine (plat du jour par jour), point d'entrée réservation.

## Composants
- Header rose `pink600` : logo + « Cantine » + recherche + panier.
- Grille 2 colonnes de cartes plat : image + libellé (`Plat aléatoire`, `Plat Lundi`, `Plat mardi`, … `Plat Vendredi`).
- Tap sur une carte → détail / [réservation](reservation-confirmee.md).

## Tokens appliqués
- Cartes : surface `neutral0`, radius 12, bordure `border`.
- Libellé plat : `bodyM`/`label` `neutral900`.
- Titre « Cantine » : `h3` `navy900`.

## Règles métier
- Menus **serveur** — jamais en dur.
- Réservation cantine **optionnelle** (parcours : abonnement → Food Pass → réservation optionnelle → scan staff → décrément quota).
- Codes possibles : `CANTEEN_RESERVATION_CLOSED`, `CANTEEN_ALREADY_RESERVED`, `MEAL_NOT_ALLOWED`, `MEAL_ALREADY_USED`.
- **Anti double-distribution** : 1 seul `meal_usage` VALID par étudiant/date/type (contrainte serveur).

## ⚠️ Divergences
- Titre « Contine » → « Cantine ».
- Header « SUPE2I FOOD » → « SUP2I FOOD ».
- Onglet nav « Contine » → « Cantine ».

## Plus tard
M8 : menu semaine + réservation + statut quota.
