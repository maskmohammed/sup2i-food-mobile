# Contrats API manquants

Aucun OpenAPI n'est fourni à ce jour. Le Mobile utilise une **couche
adaptateur/mock** alignée sur les entités SQL. **Ne jamais figer un endpoint ou
un payload comme officiel** tant que le backend ne l'a pas confirmé.

Ce fichier recense les contrats supposés, à valider côté backend.

## M2 — Authentification

- **Endpoint supposé** : `POST /auth/login` (à confirmer).
- **Requête supposée** : `{ "email": string, "password": string }`.
- **Réponse succès supposée** : session contenant au moins
  `{ token, studentId, displayName }` (cf. `AuthSession`). Forme réelle à
  confirmer (refresh token ? expiration ? profil complet ?).
- **Erreurs (par `code`)** : `UNAUTHORIZED`, `ACCOUNT_BLOCKED`,
  `ACCOUNT_SUSPENDED`, `RATE_LIMITED`, `INTERNAL_ERROR`. Enveloppe d'erreur
  supposée : `{ "code": string, "message"?: string }` — l'UI n'utilise **que**
  `code`.
- **Déconnexion** : endpoint serveur nécessaire ? (révocation token) — à
  confirmer ; le mock ne fait qu'effacer la session locale.

### Statut implémentation
- `AuthRepository` (contrat) + `MockAuthRepository` (déterministe) en place.
- `AuthController` (état) + `AuthScope`/`AuthGate` (login ↔ shell).
- Login branché : erreurs mappées par `code` → messages l10n.
- **À faire quand le backend existe** : `HttpAuthRepository` (client réel),
  stockage sécurisé du token, refresh.

## À venir (autres jalons)
- M3 Catalogue : produits, catégories, disponibilité, prix (serveur).
- M4 Panier/Créneaux : créneaux, capacités, calcul total (serveur).
- M6 Orders/QR, M8 Cantine/Food Pass : cf. state machine + catalogue de `code`.
