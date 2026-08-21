# Food Pass (QR) — Cantine (M8)

> Référence : `references/food-pass.png` · Conventions : [README.md](README.md)

## Rôle
Carte Food Pass numérique de l'étudiant : QR permanent + identité + statut.

## Composants
- Titre « Votre QR » (`h3`).
- Carte Food Pass (fond `navy900`) : « SUP2I FOOD — FOOD PASS », nom, `ID : …`, **badge de statut**, photo étudiant, **QR**.
- Statut visible ici : **Bloqué** (badge).

## Tokens appliqués
- Carte : fond `navy900`, texte `neutral0`.
- Badge Bloqué : `error` `#EF4444` + libellé « Bloqué ».
- Nom : `h3`/`label` clair ; ID : `caption`.
- États badge : Active `success` · Bloqué `error` · Perdu/Expiré `warning`/`muted`.

## Règles métier
- **1 seul Food Pass `ACTIVE`** par étudiant. Carte perdue → ancien QR invalidé immédiatement (voir [perte-food-pass.md](perte-food-pass.md)).
- **Statut jamais par couleur seule** : badge + libellé (« Bloqué », « Active »…). ✔ conforme.
- Photo étudiant modifiable **uniquement par l'Administration**, jamais côté Mobile.
- QR/état pilotés serveur ; codes possibles : `FOOD_PASS_BLOCKED`, `FOOD_PASS_LOST`, `FOOD_PASS_REVOKED`, `FOOD_PASS_EXPIRED`, `INVALID_QR`, `QR_EXPIRED`, `QR_REVOKED`.

## ⚠️ Divergences
- Bouton central « Votre QR » de la nav : **décision produit ouverte** (Food Pass vs QR de commande active selon contexte). Ne pas figer la logique de nav sans arbitrage.

## Plus tard
M8 : Food Pass + rafraîchissement statut ; lien vers déclaration de perte.
