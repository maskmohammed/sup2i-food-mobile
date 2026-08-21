# Langue — Profil / Auth (M2)

> Référence : `references/langue.png` · Conventions : [README.md](README.md)

## Rôle
Choix de la langue de l'interface. Accessible depuis le [Profil](profil.md).

## Composants
- Header rose `pink600` + titre « Langues ».
- Titre « Choisissez votre langue » (icône globe, `h3` `navy900`).
- 3 options (ligne cliquable + drapeau) :
  - **العربية** (arabe, RTL)
  - **Français** (sélectionnée : encadré `pink600`, fond `pink500` clair)
  - **Anglais**

## Tokens appliqués
- Option sélectionnée : bordure `pink600`, fond `pink500` clair.
- Options non sélectionnées : surface `neutral100`, radius 12.
- Libellés : `bodyL`/`label` `neutral900`.

## Règles métier
- l10n **FR / AR / EN** (exigence DoD).
- **AR = RTL** : bascule de direction + police **Noto Sans Arabic**.
- Choix persistant (préférence utilisateur) ; s'applique à toute l'app.

## ⚠️ Divergences
- Header « SUPE2I FOOD » → « SUP2I FOOD ».
- Nav (QR central, pas de Commandes) → nav gelée à 5 onglets.

## Plus tard
M2 : structure l10n de base (FR/AR/EN) + sélecteur relié.
