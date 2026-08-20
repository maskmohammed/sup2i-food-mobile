# Préférences de notifications — Transverse (M9)

> Référence : `references/preferences-notifications.png` · Conventions : [README.md](README.md)

## Rôle
Activer/désactiver les catégories de notifications.

## Composants
- Titre « Préférences » (`h2` `navy900`).
- Cartes à interrupteur (`Switch`) :
  - **Transactionnel** — « Statut de commande, paiement, retrait » (activé)
  - **Cantine** — « Quota, réservation, Food Pass » (activé)
  - **Promotions** — « Offres et réductions » (désactivé)
  - **Marketing** — « Actualités SUP2I FOOD » (désactivé)

## Tokens appliqués
- Cartes : surface `neutral0`, radius 12.
- Switch actif : piste/pouce `pink600` ; inactif : `muted`.
- Titre catégorie : `label`/`bodyM` `neutral900` ; description : `caption` `muted`.

## Règles métier
- Préférences persistées serveur (par catégorie).
- Le canal **Transactionnel** peut être imposé/non désactivable selon règle serveur (à confirmer côté backend).
- Anti double-submit sur changement d'état (optimistic UI + rollback si erreur).

## ⚠️ Divergences
- Aucun écart bloquant (vérifier « SUP2I FOOD » dans les libellés).

## Plus tard
M9 : préférences reliées au backend notifications.
