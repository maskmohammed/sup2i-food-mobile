# Créneau complet (état erreur) — Snack (M4)

> Référence : `references/creneau-complet.png` · Conventions : [README.md](README.md)

## Rôle
État d'erreur affiché quand le créneau choisi est plein : invite à en choisir un autre.

## Composants (gabarit d'état générique)
- Illustration ronde centrée (cercle `neutral0` + point `pink500` clair).
- Titre « Ce créneau est complet » (`h2` `neutral900`).
- Sous-texte « Choisissez-en un autre pour continuer. » (`bodyM` `muted`).
- Bouton primaire « Choisir un créneau » → [sélection créneau](selection-creneau.md).

## Tokens appliqués
- Fond : `neutral100`. Titre : `h2` `neutral900`. Sous-texte : `bodyM` `muted`.
- Bouton : primaire `pink600`, radius 12 (la maquette dessine un bouton « pill » — **aligner sur radius 12** du thème sauf décision design contraire).

## Règles métier
- Déclenché par le `code` API **`SLOT_FULL`** (et `SLOT_CLOSED` pour un créneau fermé).
- L'état est renvoyé par le serveur ; ne jamais déduire « complet » d'un calcul local.

## ⚠️ Divergences
- « creneau » → « créneau ».
- Bouton « pill » → radius 12 (cohérence thème).

## Plus tard
M4 : brancher cet état sur l'erreur de sélection/validation de créneau.
