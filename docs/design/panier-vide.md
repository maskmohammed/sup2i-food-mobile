# Panier vide (état vide) — Snack (M4)

> Référence : `references/panier-vide.png` · Conventions : [README.md](README.md)

## Rôle
État vide du [panier](panier.md) quand aucun article n'a été ajouté.

## Composants (gabarit d'état générique)
- Illustration ronde centrée (cercle `neutral0` + point `muted`).
- Titre « Votre panier est vide » (`h2` `neutral900`).
- Sous-texte « Ajoutez des produits pour commencer. » (`bodyM` `muted`).
- Bouton primaire « Découvrir le menu » → [catalogue](catalogue.md).

## Tokens appliqués
- Fond `neutral100` ; titre `h2` `neutral900` ; sous-texte `bodyM` `muted`.
- Bouton : primaire `pink600`, radius 12 (maquette « pill » → aligner sur radius 12).

## Règles métier
- État **vide** distinct de offline/timeout.
- Le CTA renvoie au catalogue pour composer une commande.

## ⚠️ Divergences
- « Decouvrir » → « Découvrir ».
- Bouton « pill » → radius 12.

## Plus tard
M4 : état vide du panier + CTA vers catalogue.
