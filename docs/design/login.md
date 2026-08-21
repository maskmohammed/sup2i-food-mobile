# Login — Auth (M2)

> Référence : `references/login.png` · Logo : `../../assets/images/sup2i_logo.png`
> Conventions : [README.md](README.md) · **Implémenté** : `lib/features/auth/presentation/login_page.dart`

## Rôle
Connexion étudiant (compte fourni par l'Administration). Pas d'auto-inscription.

## Structure (base maquette Figma, améliorée)
- **Header blanc** (`neutral0`) : logo applicatif (emblème toque + couverts) + wordmark « SUP2I FOOD » + tagline « Reconnu par l'État ».
- **Panneau rose** (`pink600`, coins supérieurs arrondis 28) occupant le reste de l'écran, contenant le formulaire.

## Composants
- Logo via `Image.asset` (`assets/images/sup2i_logo.png`) avec `errorBuilder` de repli.
- Titre + sous-titre.
- 2 champs en **pilule blanche** : e-mail (icône enveloppe), mot de passe (icône cadenas + œil voir/masquer).
- Bouton primaire « Se connecter ».

## Tokens appliqués
- Panneau : fond `pink600` `#C31A6F`.
- Titre : `headlineSmall` (Montserrat) en **`navy900`** (lisible sur rose).
- Sous-titre + labels de champ : **`neutral0` (blanc)** — contraste corrigé vs maquette.
- Champs : fond `neutral0`, pilule (radius 30), texte `neutral900`, hint `muted`, icônes `navy900` ; focus = bordure `navy900`, erreur = bordure `error` + message en blanc.
- **CTA « Se connecter » : fond `navy900`, texte blanc, pilule** — remplace le rose-sur-rose de la maquette (accessibilité).

## Règles métier
- Auth serveur ; aucune règle locale. Le Mobile ne confirme jamais un paiement/état localement.
- Erreurs par `code` : `UNAUTHORIZED`, `ACCOUNT_BLOCKED`, `ACCOUNT_SUSPENDED` → messages mappés, jamais le `message` brut (branché en M2).
- **Anti double-submit** sur « Se connecter » (état loading : spinner + champs désactivés).
- Aucun secret/log sensible (jamais logger e-mail ni mot de passe).
- l10n FR/AR/EN + RTL.

## ⚠️ Divergences maquette → corrigées
- Contraste « rose sur rose » du bouton → **CTA navy**. ✔
- Sous-titre/labels peu lisibles → **blanc**. ✔
- (Reste maquette conforme : header blanc + panneau rose conservés comme base.)

## État
Implémenté (UI + états + validation + stub de soumission → app shell). L'appel réseau réel arrive en **M2**.
