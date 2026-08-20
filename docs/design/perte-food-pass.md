# Perte du Food Pass — Cantine (M8)

> Référence : `references/perte-food-pass.png` · Conventions : [README.md](README.md)

## Rôle
Déclaration de perte/vol/dommage de la carte Food Pass.

## Composants
- Titre « Perte de mon Food Pass » (`h3` `navy900`).
- Encart d'alerte (fond `error` clair) : **« Action irréversible »** — « Votre ancien QR sera invalidé immédiatement. Abonnement, quota et historique sont conservés. »
- Groupe radio « Pourquoi déclarez-vous la perte ? » : Carte endommagée / Carte volée / **Carte perdue** (sélectionnée).
- Bouton **destructif** « Confirmer la perte » (`error`).

## Tokens appliqués
- Encart alerte : fond `error` `#EF4444` très clair, icône + texte foncé.
- Radio sélectionné : bordure/point `pink600`.
- Bouton « Confirmer la perte » : plein `error` (action destructive), radius 12.

## Règles métier
- **Action irréversible** confirmée côté serveur : invalidation immédiate de l'ancien QR.
- Le **remplacement conserve** abonnement, quotas et historique.
- **Anti double-submit** + confirmation explicite obligatoire.
- Motif transmis au serveur ; l'invalidation n'est **jamais** décidée localement.

## ⚠️ Divergences
- Titre écran « Foos Pass » → « Food Pass ».

## Plus tard
M8 : flux de déclaration + confirmation + regénération QR (serveur).
