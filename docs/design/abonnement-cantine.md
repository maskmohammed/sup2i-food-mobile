# Abonnement / quota cantine — Cantine (M8)

> Référence : `references/abonnement-cantine.png` · Conventions : [README.md](README.md)

## Rôle
État de l'abonnement cantine, quota de repas restants, historique hebdo.

## Composants
- Carte plan (fond `navy900`) : « Plan Étudiant Standard » + **badge « Actif »** + « Valide jusqu'au 30 juin 2026 ».
- Compteur quota : **« 8 / 12 » repas restants cette semaine** (`display`/`h1`).
- Barre de progression + « Se renouvelle chaque lundi ».
- Section « Historique » : « Semaine du 11 août — 12/12 repas utilisés ».

## Tokens appliqués
- Carte plan : fond `navy900`, texte `neutral0` ; badge Actif : `success`.
- Compteur « 8 / 12 » : `display`/`h1` `navy900`.
- Barre de progression : remplissage `pink600`, piste `neutral100`.
- Libellés secondaires : `bodyM`/`caption` `muted`.

## Règles métier
- **Abonnement activé par l'Administration** — le Mobile n'active jamais.
- **Quota calculé serveur** ; le Mobile affiche, ne recalcule pas. Renouvellement hebdomadaire (lundi) côté serveur.
- Codes possibles : `SUBSCRIPTION_INACTIVE`, `ENTITLEMENT_EXPIRED`, `QUOTA_EXHAUSTED`, `DAILY_LIMIT_REACHED`.
- **Statut jamais par couleur seule** : badge « Actif » + libellé.

## ⚠️ Divergences
- Aucun écart bloquant repéré (vérifier le format d'éventuels montants en `DH`).

## Plus tard
M8 : abonnement + quota + historique (lecture serveur).
