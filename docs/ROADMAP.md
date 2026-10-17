# SUP2I FOOD — Mobile · Roadmap (état d'avancement)

> Dernière mise à jour : 2026-08-28 · Branche de référence : `develop`

**Contrainte clé du projet** : le **backend réel (OpenAPI) n'est pas disponible**.
Tout ce qui exige l'**autorité serveur** (auth réelle, paiement, statuts temps
réel, push, stock/quotas, vraies données) est volontairement en **mock**, derrière
des repositories **abstraits** (interfaces) prêts à brancher le backend — le swap
`Mock*` → `Http*` se fait de façon isolée à la racine de l'app.

---

## ✅ Fait (dans `develop`, en mock)

| Jalon | Contenu livré |
|---|---|
| **M0 / M1** | Bootstrap, app shell, bottom nav 5 onglets, thème clair **+ sombre**, l10n **FR / AR / EN + RTL** |
| **M2 (mock)** | Login (validation, gestion d'erreurs par `code` API) **+ mode invité + mur de connexion contextuel** (`AuthGuard`) |
| **M3** | Catalogue (18 produits, catégories, détail, allergènes en chips), **recherche** (debounce ~280 ms, historique récent, auto-suggestion), **icônes de catégories Phosphor** (couleur d'état) |
| **M4** | Panier, sélection de créneaux, **feuille d'options** (suppléments / frites / boisson), **édition de ligne sans doublon**, miniature produit sur les lignes |
| **M6** | Commande créée (`AWAITING_PAYMENT`), écran de suivi, **QR réel** (qr_flutter), historique multi-semaines à statuts variés |
| **M7 (partiel)** | Écran dédié **« commande prête »** + progression de statuts **simulée** en mock (le temps réel serveur reste à faire) |
| **M8** | Cantine (menu de la semaine), abonnement / quota, **Food Pass QR permanent**, déclaration de perte |
| **M9 (mock)** | Centre de notifications, préférences par catégorie, **badge cloche réactif** (composant partagé icône + badge) |
| **M10 (mock)** | Favoris, promotions, fidélité |
| **M11** | Tests (**112 verts**), **golden tests** (5 écrans, exclus de la CI Linux), **passe accessibilité** (labels sémantiques, QR annoncés, cibles ≥ 48 dp), **CI** GitHub Actions (format + analyze + test), **charte d'animation** + `prefers-reduced-motion`, **skeleton screens**, **pull-to-refresh**, **retour haptique**, données mock enrichies |

**Extras transverses** : mode sombre, FR/AR/EN, persistance langue/thème
(`shared_preferences`), photos produits **Unsplash (dev-only)**, bouton debug
« Reset mock data » (`kDebugMode`).

---

## ⛔ Pas encore fait — et pourquoi

| Élément | Pourquoi |
|---|---|
| **M2 — auth réelle** | Nécessite le backend (login/token réels). Aujourd'hui : mock déterministe. |
| **M5 — vertical slice réel** (Admin crée un produit → Mobile l'affiche → panier → commande) | Nécessite le backend **et** l'app Web Admin. |
| **M7 — temps réel** (statut de commande en direct) | Nécessite WebSocket/SSE côté serveur. Aujourd'hui : progression **simulée**. |
| **M9 — push réel** (FCM / APNs) | Nécessite backend + service push. Aujourd'hui : liste mock. |
| **Paiement** (`CASH` / `CARD_TPE`) | Jamais confirmé côté Mobile **par règle gelée** ; le flux réel dépend du backend / TPE. |
| **Vraies photos produits** | Les photos Unsplash sont **dev-only** (voir `docs/design/decisions.md` D9) — à remplacer avant toute mise en production (une photo ≠ du plat réellement servi induit le client en erreur). |
| **Implémentations `Http*`** des repositories | L'architecture est prête (interfaces abstraites), mais **aucun contrat OpenAPI** n'est fourni pour coder les vrais appels. |
| **M12 — pilote e2e** | Nécessite un backend complet + vraies données + appareils réels. |

---

## 👉 Prochaine étape logique

Dès que le **backend + OpenAPI** sont fournis :
1. Écrire les repositories `Http*` (swap isolé à la racine, interfaces déjà en place).
2. Brancher **M2 / M5 / M7 / M9** réels.
3. Remplacer les photos Unsplash par les vraies photos produits.
4. Enchaîner **M11 hardening** final puis **M12 pilote**.

---

## Décisions de design associées

Voir `docs/design/decisions.md` (D1 → D12) pour le **pourquoi** de chaque choix
produit/design (bouton QR central, écran commande prête, skeletons, charte
d'animation, golden tests, accessibilité, photos Unsplash dev-only, haptique,
auto-suggestion, icônes Phosphor, mode invité + mur de connexion).
