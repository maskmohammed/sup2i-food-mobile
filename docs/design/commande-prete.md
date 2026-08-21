# Commande prête — Snack (M7)

> Référence : `references/commande-prete.png` · Conventions : [README.md](README.md)

## Rôle
Écran dédié quand la commande passe à l'état **READY** : numéro à présenter au comptoir + accès au QR de retrait.

## Composants
- Grande coche de succès (cercle `success`).
- Titre « Votre Commande est prête ! » (`h2` `navy900`).
- Carte navy `navy900` avec « Numéro » + code (`A14789`) en grand.
- Sous-texte « Présenter ce numéro au comptoir ».
- Bouton primaire « Voir le QR de retrait ».
- Horodatage discret « Il y a 3 min ».

## Tokens appliqués
- Coche : `success` `#22C55E`.
- Carte numéro : fond `navy900`, texte `neutral0` ; numéro en `h1`/`display`.
- Titre : `h2` `navy900`. Bouton : primaire rose plein.

## Règles métier
- Correspond à l'état **READY** de la state machine (`… PREPARING → READY → COLLECTED …`).
- **READY jamais signalé par la couleur seule** : coche + libellé texte « prête ».
- Le passage à READY est **piloté serveur** (staff), jamais décidé localement.
- Le QR de retrait est la preuve de collecte → `COLLECTED` après scan staff.

## ⚠️ Divergences
- Header « SUPE2I FOOD » → « SUP2I FOOD ».

## Plus tard
M7 : écran temps réel (push/refresh) déclenché par l'état serveur READY.
