# Favoris — Profil (M10)

> Référence : `references/favoris.png` · Conventions : [README.md](README.md)

## Rôle
Liste « Mes favoris » : produits marqués par l'étudiant.

## Composants
- Header rose `pink600` + titre « Favoris ».
- Titre section « Mes favoris » (`h2`).
- Grille 2 colonnes de cartes produit (identiques au [catalogue](catalogue.md)) : image, nom, prix, **cœur (favori actif)** + bouton ajout panier.

## Tokens appliqués
- Cartes : surface `neutral0`, radius 12.
- Cœur actif : `pink500`/`pink600`.
- Nom : `bodyM` ; prix : `label` `navy900`.

## Règles métier
- Liste favoris **serveur** (si l'API le prévoit — jalon M10 « si API prête »).
- Prix format `DH`.
- États : vide (« aucun favori »), offline.

## ⚠️ Divergences
- Titre « Favories » → « Favoris ».
- « 40 MAD / 25 MAD » → `40,00 DH` / `25,00 DH`.

## Plus tard
M10 : favoris (conditionné à la disponibilité de l'API).
