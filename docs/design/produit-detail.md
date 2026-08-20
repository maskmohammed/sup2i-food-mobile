# Détail produit + options — Snack (M3–M4)

> Référence : `references/produit-detail.png` · Conventions : [README.md](README.md)

## Rôle
Fiche produit avec suppléments, accompagnement, boisson, quantité, ajout panier.

## Composants
- Grande image produit en tête.
- Nom (`h3`), description (`bodyM` `muted`), prix (`h3`/`label` `pink600`).
- Durée de préparation (icône horloge + « 15 Minutes »).
- Sélecteur de quantité `- 1 +`.
- Listes d'options à cocher/incrémenter : « Sélectionnez des suppléments », « Accompagnement », « Sélectionnez une boisson » (chaque ligne : libellé + prix delta + bouton `+`).
- Encart d'info (fond `pink500` clair) : « Jusqu'à 2 sauces incluses, +3dh par sauce supplémentaire ».
- Bouton primaire « Ajouter au panier ».

## Tokens appliqués
- Prix principal : `pink600`. Deltas d'option : `label` `navy900`.
- Boutons `+` d'option : `pink600` (actif).
- Encart d'info : fond `pink500` très clair, texte foncé + icône info.
- Bouton « Ajouter au panier » : primaire (rose plein, radius 12).

## Règles métier
- **Allergènes en chips texte** obligatoires ici (jamais uniquement sur la photo).
- Options, prix et deltas **serveur** ; le total se recalcule côté serveur (le Mobile n'est pas autorité). Option invalide → `code` `INVALID_PRODUCT_OPTION`.
- Règle des quotas d'options (ex. « 2 sauces incluses ») vient du serveur, pas codée en dur.
- Disponibilité vérifiée à l'ajout (`OUT_OF_STOCK` / `PRODUCT_UNAVAILABLE`).
- Prix format `DH`.

## ⚠️ Divergences
- Deltas « +5dh / +3dh / +10dh » → format `DH` cohérent (`+5,00 DH`).
- Prix « 40 MAD » → `40,00 DH`.

## Plus tard
M3 : affichage détail + allergènes ; M4 : composition panier + anti double-submit.
