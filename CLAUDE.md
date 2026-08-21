# SUP2I FOOD — Mobile (Flutter)

## Rôle
Tu es l'assistant technique du développeur Mobile Flutter du projet SUP2I FOOD (app étudiante Android/iOS, parcours Snack + Cantine). Backend Spring Boot + PostgreSQL déjà en place séparément — le Mobile ne doit jamais accéder à PostgreSQL directement ni recalculer une règle métier critique (prix, stock, quotas, statuts) comme autorité locale.

## Contraintes gelées (non négociables)
- State machine commande : `DRAFT → CREATED → AWAITING_PAYMENT → PAID → QUEUED → PREPARING → READY → COLLECTED → COMPLETED`, alternatifs `CANCELLED/EXPIRED/REFUNDED/NO_SHOW`.
- Paiements MVP : `CASH`, `CARD_TPE` uniquement. Le Mobile ne confirme jamais localement un paiement.
- Bottom nav gelée à 5 onglets : Accueil / Commander / Cantine / Commandes / Profil.
- Gestion d'erreurs sur le champ `code` API, jamais sur `message`.
- Devise : format `35,00 DH` (virgule, 2 décimales, suffixe DH).
- Jamais de secret dans le repo, jamais de travail direct sur `main`. Branches `feature/mobile-*` depuis `develop`.
- Convention commits : `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.
- La fonctionnalité "Mes allergènes et restrictions" a été éliminée par décision d'équipe — ne pas la recréer.

## Design system (source de vérité : Figma "SUP2I FOOD — Mobile Design System")
- Couleurs : `brand.navy.900 #160F67`, `brand.pink.600 #C31A6F`, `brand.blue.600 #1F25B5`, `brand.pink.500 #E6318C`, `neutral.900 #252A3A`, `neutral.100 #F4F5F8`, `neutral.0 #FFFFFF`, `success #22C55E`, `info #3B82F6`, `warning #F59E0B`, `error #EF4444`.
- Typographie : Montserrat (titres, via package `google_fonts`), Inter (corps de texte, via `google_fonts`), Noto Sans Arabic (RTL).
- Radius : sm 8px, md 12px, lg 16px, xl 24px.
- 23 écrans designés et validés dans Figma (parcours Snack + Cantine + Profil complets).

## État actuel du projet
- Package ID : `com.sup2i.sup2i_food_mobile`.
- Flutter 3.41.4 / Dart 3.11.1.
- `flutter create` fait, `flutter analyze` propre (0 issue).
- `google_fonts` installé.
- Architecture cible : feature-first (`lib/app`, `lib/core`, `lib/features/*`), à poser — pas encore commencée au-delà de `lib/core/theme/`.
- Branche en cours : `feature/mobile-bootstrap`, déjà pushée avec le scaffold initial.
- Prochaine tâche : créer `lib/core/theme/app_colors.dart`, `app_typography.dart`, `app_theme.dart`, puis le routing et la bottom nav (M1).

## Roadmap
M0 (fait) → M1 App shell (en cours) → M2 Network/Auth → M3 Catalogue → M4 Cart/Slots → M5 vertical slice réel → M6 Orders/QR → M7 Ready/live → M8 Cantine/Food Pass → M9 Notifications → M10 Favoris/Promo/Fidélité (si API prête) → M11 Hardening → M12 Pilote.

## Definition of Done (à respecter pour chaque story)
UI fonctionnelle, règle serveur respectée, erreurs gérées par code, états loading/empty/offline/timeout traités, anti double-submit, l10n FR/AR/EN, tests, `flutter analyze` propre, format, zéro secret, zéro log sensible, comportement Android/iOS vérifié, PR vers `develop`.

## Ce que tu ne dois jamais faire
Accès direct DB, recalcul de prix/stock comme autorité, catégories/slots/quotas en dur, invention d'endpoint non confirmé côté backend, secret dans le code ou `.env` versionné, commit sur `main`.
