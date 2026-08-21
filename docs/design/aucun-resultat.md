# Aucun résultat (recherche vide) — Snack (M3)

> Référence : `references/aucun-resultat.png` · Conventions : [README.md](README.md)

## Rôle
État vide de la recherche/filtre du [catalogue](catalogue.md) quand rien ne correspond.

## Composants (gabarit d'état générique)
- Illustration ronde centrée (cercle `neutral0` + point `muted`).
- Titre « Aucun résultat » (`h2` `neutral900`).
- Sous-texte « Essayez un autre mot-clé ou une autre catégorie. » (`bodyM` `muted`).
- Bouton primaire « Voir tout le catalogue ».

## Tokens appliqués
- Fond `neutral100` ; titre `h2` `neutral900` ; sous-texte `bodyM` `muted`.
- Bouton : primaire `pink600`, radius 12 (maquette « pill » → aligner sur radius 12).

## Règles métier
- État **vide** (pas une erreur) : distinct de offline/timeout.
- Le CTA réinitialise recherche/filtres et renvoie au catalogue complet.

## ⚠️ Divergences
- « resultat / mot-cle / categorie » → « résultat / mot-clé / catégorie ».
- Bouton « pill » → radius 12.

## Plus tard
M3 : état vide de la recherche catalogue.
