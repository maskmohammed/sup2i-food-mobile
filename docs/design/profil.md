# Profil — Profil (M1–M2)

> Référence : `references/profil.png` · Conventions : [README.md](README.md)

## Rôle
Compte étudiant : identité + accès aux réglages et sous-écrans.

## Composants
- Header rose `pink600` + titre « Profil ».
- Carte identité : avatar, nom (`Chnaf Yahya`), `ID étudiant : …`.
- Liste de lignes (icône + libellé + chevron) :
  - Mes favoris → [favoris.md](favoris.md)
  - Notifications → [preferences-notifications.md](preferences-notifications.md)
  - Langue (FR/AR/EN)
  - Mon abonnement Cantine → [abonnement-cantine.md](abonnement-cantine.md)
  - Aide et support
- Bouton **destructif** « Déconnexion » (`error`).

## Tokens appliqués
- Lignes : surface `neutral0`/`neutral100`, radius 12, chevron `muted`.
- Nom : `h3`/`label` `neutral900` ; ID : `caption` `muted`.
- « Déconnexion » : plein/outline `error`.

## Règles métier
- Langue : l10n **FR/AR/EN** (AR = RTL, police Noto Sans Arabic).
- Déconnexion : purge du token, retour au [login](login.md).

## ⚠️ Divergences (important)
- La maquette affiche **« Mes allergènes et restrictions »** → **feature éliminée** : **ne PAS l'implémenter**. Retirer la ligne.
- Vérifier libellé « Profil » (l'onglet nav est « Profil »).

## Plus tard
M1 : écran statique ; M2 : données compte réelles + déconnexion.
