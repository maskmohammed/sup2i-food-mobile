# Réservation confirmée — Cantine (M8)

> Référence : `references/reservation-confirmee.png` · Conventions : [README.md](README.md)

## Rôle
Confirmation d'une réservation de repas cantine, avec possibilité d'annuler avant l'heure limite.

## Composants
- Coche de succès (cercle `success`).
- Titre « Réservation confirmée » (`h2`) + « Votre repas vous attend à la cantine ».
- Carte repas : libellé (`Poulet rôti, riz, légumes`), « Menu du jour », **Date** (`Mardi 19 août`) et **« Annulation possible jusqu'à 11h00 »**.
- Bouton **secondaire destructif** « Annuler la réservation » (outline `error`).
- Bouton primaire « Retour à la cantine ».

## Tokens appliqués
- Coche : `success`. Titre : `h2` `navy900`.
- Carte repas : surface `neutral0`, radius 12.
- « Annuler » : outline `error`, texte `error`.
- « Retour à la cantine » : primaire rose plein.

## Règles métier
- Réservation et fenêtre d'annulation **pilotées serveur** (heure limite = donnée serveur, pas en dur).
- **Bouton « Annuler » visible uniquement avant l'heure limite / avant distribution** — masqué/désactivé passé le délai (analogue à « annuler avant PREPARING » côté Snack).
- Anti double-submit sur annulation ; codes : `CANTEEN_RESERVATION_CLOSED`, `MEAL_ALREADY_USED`.

## ⚠️ Divergences
- Accents manquants (« confirmee », « attend a la cantine ») → orthographe correcte.

## Plus tard
M8 : réservation + annulation conditionnelle.
