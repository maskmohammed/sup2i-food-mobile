# Catalogue produits — Snack (M3)

> Référence : `references/catalogue.png` · Conventions : [README.md](README.md)

## Rôle
Liste des produits « Commander », filtrable par catégorie.

## Composants
- Header rose `pink600` : logo + « Nos Produits » + recherche + panier.
- Rangée de chips catégories : `Tous / Tacos / Pizza / Pasticio / Boisson / Dessert` (chip actif surligné).
- Grille de cartes produit (2 colonnes) : image, nom, sous-libellé, prix, icône **favori (cœur)** + bouton **ajout panier**.

## Tokens appliqués
- Chip actif : fond `pink600`, texte `neutral0` ; inactif : fond `neutral0`/`neutral100`, texte `neutral900`.
- Carte produit : surface `neutral0`, radius 12, bordure `border`.
- Nom : `bodyM` `neutral900` ; catégorie : `caption` `muted` ; prix : `label` `navy900`.
- Cœur favori : `pink500` si actif, `muted` sinon.

## Règles métier
- Catégories, disponibilité et prix **serveur** (jamais en dur).
- Produit indisponible → carte état « Unavailable » + `code` `PRODUCT_UNAVAILABLE` / `OUT_OF_STOCK` au moment d'ajouter.
- **Allergènes** produit : à afficher en **chips texte** (sur le détail), jamais uniquement via la photo.
- Prix format `DH`.

## ⚠️ Divergences
- Prix « 40 MAD / 5 MAD » → `40,00 DH` / `5,00 DH`.
- Nav (QR central, pas de Commandes) → nav gelée 5 onglets.

## Plus tard
M3 : liste + filtres + favoris ; M4 : ajout au panier avec options.
