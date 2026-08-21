# Notifications (centre) — Transverse (M9)

> Référence : `references/notifications.png` · Conventions : [README.md](README.md)

## Rôle
Centre de notifications : événements commande, paiement, quota, réservation.

## Composants
- Titre « Notifications » (`h2` `navy900`).
- Liste de cartes notification : pastille de couleur (type) + titre + sous-libellé + horodatage relatif (`Il y a 5min`, `Hier`).
- Cartes **non lues** mises en avant (fond `pink500` clair) vs lues (surface `neutral0`).
- Exemples : « Votre demande est prête » (`READY`), « Paiement confirmé » (`PAID`), « Quota faible » (`warning`), « Réservation confirmée ».

## Tokens appliqués
- Pastilles par type : prête `success` · paiement `blue600`/`info` · quota faible `warning` · réservation `info`.
- Titre notif : `label`/`bodyM` `neutral900` ; sous-libellé : `caption` `muted` ; horodatage : `caption` `muted`.
- Carte non lue : fond `pink500` clair.

## Règles métier
- Notifications **serveur** (push M9) ; le type/état n'est pas décidé localement.
- **Paiement confirmé** vient du serveur — le Mobile ne confirme jamais un paiement localement.
- Le type doit rester lisible **sans la couleur seule** (titre texte explicite).

## ⚠️ Divergences
- « Paiment confirme » → « Paiement confirmé ».

## Plus tard
M9 : centre de notifications + push + état lu/non lu.
