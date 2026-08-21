# Historique commandes — Snack (M6)

> Référence : `references/historique-commandes.png` · Conventions : [README.md](README.md)

## Rôle
Liste « Mes commandes » passées avec statut, montant, note et favori.

## Composants
- Titre « Mes commandes » (`h2`).
- Cartes commande : vignette, n° (`Commande #A1949`), date/heure, résumé produits, **badge de statut**, montant, note (étoiles), icône favori.
- Statuts visibles : **Retirée** (`COLLECTED`, `success`), **Annulée** (`CANCELLED`, `error`).

## Tokens appliqués
- Carte : peut être colorée (`pink600` / `navy900`) selon maquette, mais **le statut reste porté par un badge + libellé texte**, jamais par le fond seul.
- Badge Retirée : `success` ; Annulée : `error`.
- N° et résumé : `bodyM` ; montant : `label` ; date : `caption` `muted`.
- Étoiles de note : `warning`/`pink600`.

## Règles métier
- Statuts = état serveur de la state machine (COLLECTED, CANCELLED, EXPIRED, REFUNDED…).
- **Statut jamais par couleur seule** → badge + libellé (accessibilité).
- Montants format `45,00 DH`.
- Notation possible seulement sur commandes éligibles (règle serveur).

## ⚠️ Divergences
- « 45 DHS / 30 DHS » → `45,00 DH` / `30,00 DH`.
- Cet écran **n'a pas d'onglet dédié** dans la nav gelée (Commandes = onglet) : à cadrer — l'onglet **Commandes** doit mener ici.

## Plus tard
M6 : historique + détail commande + suivi statut.
