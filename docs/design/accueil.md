# Accueil — Snack (M3)

> Référence : `references/accueil.png` · Conventions : [README.md](README.md)

## Rôle
Point d'entrée : recherche, mise en avant, catégories, produits populaires.

## Composants
- Header rose `pink600` : logo + « Bienvenue chez SUP2I FOOD » + icône panier.
- Champ de recherche « Rechercher des produits » (radius 12).
- Bannière promo (carte navy `navy900`, visuel).
- Section « Nos coups de cœur » : cartes produit horizontales.
- Section « Nos Catégories » : chips ronds `pink600` avec icône + libellé.
- Section « Nos Produits » + lien « Voir Plus » (`blue600`).
- Cartes produit : image, nom, prix, bouton d'ajout rond.
- Bottom nav.

## Tokens appliqués
- Header : `pink600`. Titres de section : `h3` `neutral900`.
- Nom produit : `bodyM`/`label` ; prix : `label` (mise en avant) `navy900`.
- Lien « Voir Plus » : `blue600`, `label`.
- Chips catégories : fond `pink600`, texte/icône `neutral0`.

## Règles métier
- Catalogue, catégories et prix viennent du serveur — **jamais en dur**, jamais recalculés.
- Prix affichés au format `40,00 DH`.
- États à prévoir : loading (skeletons), vide (aucun produit), offline/timeout.

## ⚠️ Divergences
- Prix « 40 MAD / 25 MAD » → `40,00 DH` / `25,00 DH`.
- Titre header « SUPE2I FOOD » → « SUP2I FOOD ».
- Nav sans onglet Commandes + QR central → nav gelée à 5 onglets.

## Plus tard
M3 : catalogue réel + recherche ; M5 : slice vertical (Admin crée produit → visible ici).
