# Panier — Snack (M4)

> Référence : `references/panier.png` · Conventions : [README.md](README.md)

## Rôle
Récapitulatif des articles, choix du créneau de retrait, total, passage commande.

## Composants
- Titre « Mon Panier » (`h2`/`h3`).
- Cartes article : image, nom, prix, sélecteur quantité `- 1 +`, bouton suppression.
- Ligne « Créneau de retrait » (carte cliquable `pink500` clair, chevron) → écran [sélection créneau](selection-creneau.md).
- Bloc totaux : « Sous-Total » et **« TOTAL »** (`label`/`h3`).
- Bouton primaire « Commander ».

## Tokens appliqués
- Cartes article : surface `neutral0`, radius 12.
- Ligne créneau : fond `pink500` clair, icône horloge, texte `neutral900`.
- Total : `h3` `neutral900` ; sous-total : `bodyM` `muted`.
- Bouton « Commander » : primaire rose plein.

## Règles métier
- **Total calculé serveur** — le Mobile affiche, ne fait pas autorité.
- Prix/total format `90,00 DH`.
- Créneau requis avant commande ; créneau fermé/plein → `SLOT_CLOSED` / `SLOT_FULL`.
- Limite de commandes actives → `MAX_ACTIVE_ORDERS_REACHED`.
- **Anti double-submit** sur « Commander » (crée la commande `DRAFT → CREATED`).
- États : panier vide (écran dédié à venir), offline/timeout.

## ⚠️ Divergences
- « 90,00 MAD » → `90,00 DH`.
- Nav (QR central) → nav gelée 5 onglets.

## Plus tard
M4 : panier + créneaux ; M6 : création commande + statuts.
