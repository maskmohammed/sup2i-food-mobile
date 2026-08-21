import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/error/api_codes.dart';
import '../features/canteen/domain/canteen.dart';
import '../features/notifications/domain/app_notification.dart';
import '../features/orders/domain/order.dart';

/// Localisation minimale maison (M1) — FR / AR / EN + direction RTL pour l'arabe.
///
/// Volontairement sans dépendance (`flutter_localizations` / `intl` / `.arb`)
/// tant que l'environnement ne permet pas de `pub get`. La forme (delegate,
/// `of(context)`, `supportedLocales`) reproduit l'API officielle pour une
/// migration directe vers les fichiers `.arb` en M2.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  /// Langues supportées (FR par défaut, AR en RTL, EN).
  static const List<Locale> supportedLocales = <Locale>[
    Locale('fr'),
    Locale('ar'),
    Locale('en'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Delegates à passer à `MaterialApp.localizationsDelegates`.
  ///
  /// Inclut des replis Material/Widgets qui acceptent fr/ar/en (les libellés
  /// natifs Material restent en anglais tant que `flutter_localizations` n'est
  /// pas ajouté — prévu en M2). Sans ce repli, forcer une locale non-`en`
  /// déclenche « No MaterialLocalizations found ».
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        AppLocalizations.delegate,
        _FallbackMaterialLocalizationsDelegate(),
        _FallbackCupertinoLocalizationsDelegate(),
        _FallbackWidgetsLocalizationsDelegate(),
      ];

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  /// Direction du texte selon la langue (arabe = RTL).
  TextDirection get textDirection =>
      locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr;

  String _t(String key) =>
      (_values[locale.languageCode] ?? _values['fr']!)[key]!;

  String get appTitle => _t('appTitle');

  // Onglets de la bottom nav (servent aussi de titres d'écran).
  String get navHome => _t('navHome');
  String get navOrder => _t('navOrder');
  String get navCanteen => _t('navCanteen');
  String get navOrders => _t('navOrders');
  String get navProfile => _t('navProfile');

  // Messages provisoires des écrans (jalon « à venir »).
  String get homeMessage => _t('homeMessage');
  String get orderMessage => _t('orderMessage');
  String get canteenMessage => _t('canteenMessage');
  String get ordersMessage => _t('ordersMessage');
  String get profileMessage => _t('profileMessage');

  // Écran Login.
  String get loginBrandTagline => _t('loginBrandTagline');
  String get loginTitle => _t('loginTitle');
  String get loginSubtitle => _t('loginSubtitle');
  String get loginEmailLabel => _t('loginEmailLabel');
  String get loginEmailHint => _t('loginEmailHint');
  String get loginPasswordLabel => _t('loginPasswordLabel');
  String get loginPasswordHint => _t('loginPasswordHint');
  String get loginSubmit => _t('loginSubmit');
  String get loginHelper => _t('loginHelper');
  String get loginEmailRequired => _t('loginEmailRequired');
  String get loginEmailInvalid => _t('loginEmailInvalid');
  String get loginPasswordRequired => _t('loginPasswordRequired');
  String get loginShowPassword => _t('loginShowPassword');
  String get loginHidePassword => _t('loginHidePassword');

  // Profil.
  String get profileLogout => _t('profileLogout');

  // Catalogue.
  String get catalogueAll => _t('catalogueAll');
  String get catalogueEmpty => _t('catalogueEmpty');
  String get retry => _t('retry');
  String get productUnavailable => _t('productUnavailable');
  String get addToCartComingSoon => _t('addToCartComingSoon');

  // Détail produit.
  String get addToCart => _t('addToCart');
  String get allergensLabel => _t('allergensLabel');
  String get minutesSuffix => _t('minutesSuffix');
  String get optionIncluded => _t('optionIncluded');

  // Panier & créneaux.
  String get cartTitle => _t('cartTitle');
  String get cartEmptyTitle => _t('cartEmptyTitle');
  String get cartEmptyHint => _t('cartEmptyHint');
  String get discoverMenu => _t('discoverMenu');
  String get subtotalLabel => _t('subtotalLabel');
  String get totalLabel => _t('totalLabel');
  String get totalIndicativeNote => _t('totalIndicativeNote');
  String get checkout => _t('checkout');
  String get checkoutComingSoon => _t('checkoutComingSoon');
  String get addedToCart => _t('addedToCart');
  String get pickupSlotLabel => _t('pickupSlotLabel');
  String get chooseSlot => _t('chooseSlot');
  String get noSlotSelected => _t('noSlotSelected');
  String get slotAvailable => _t('slotAvailable');
  String get slotAlmostFull => _t('slotAlmostFull');
  String get slotFull => _t('slotFull');
  String get slotClosed => _t('slotClosed');

  /// Message utilisateur dérivé d'un `code` d'erreur API (jamais du `message`
  /// serveur). Repli générique pour tout code non spécifiquement traité.
  String errorMessage(String code) {
    switch (code) {
      case ApiCodes.unauthorized:
        return _t('errUnauthorized');
      case ApiCodes.accountBlocked:
        return _t('errAccountBlocked');
      case ApiCodes.accountSuspended:
        return _t('errAccountSuspended');
      case ApiCodes.rateLimited:
        return _t('errRateLimited');
      case ApiCodes.networkError:
        return _t('errNetwork');
      case ApiCodes.maxActiveOrdersReached:
        return _t('errMaxOrders');
      case ApiCodes.invalidOrderStatus:
        return _t('errInvalidOrderStatus');
      case ApiCodes.slotFull:
        return _t('errSlotFull');
      case ApiCodes.slotClosed:
        return _t('errSlotClosed');
      default:
        return _t('errGeneric');
    }
  }

  // Commandes / paiement / suivi.
  String get paymentSheetTitle => _t('paymentSheetTitle');
  String get paymentCash => _t('paymentCash');
  String get paymentCardTpe => _t('paymentCardTpe');
  String get paymentNote => _t('paymentNote');
  String get confirmOrder => _t('confirmOrder');
  String get orderNumberLabel => _t('orderNumberLabel');
  String get presentAtCounter => _t('presentAtCounter');
  String get yourQr => _t('yourQr');
  String get cancelOrder => _t('cancelOrder');
  String get tlPaymentConfirmed => _t('tlPaymentConfirmed');
  String get tlOrderReceived => _t('tlOrderReceived');
  String get tlPreparing => _t('tlPreparing');
  String get tlOrderReady => _t('tlOrderReady');
  String get ordersEmpty => _t('ordersEmpty');
  String get refresh => _t('refresh');
  String get orderReadyTitle => _t('orderReadyTitle');
  String get queueAheadSuffix => _t('queueAheadSuffix');
  String get etaLabel => _t('etaLabel');

  /// Libellé localisé d'un statut de commande.
  String orderStatusLabel(OrderStatus status) => _t('status_${status.name}');

  // Accueil.
  String get homeWelcome => _t('homeWelcome');
  String get homeSearchHint => _t('homeSearchHint');
  String get homeFavorites => _t('homeFavorites');
  String get homeCategories => _t('homeCategories');
  String get homeProducts => _t('homeProducts');
  String get seeMore => _t('seeMore');

  // Cantine / Food Pass / abonnement.
  String get foodPassPageTitle => _t('foodPassPageTitle');
  String get subscriptionPageTitle => _t('subscriptionPageTitle');
  String get foodPassButton => _t('foodPassButton');
  String get subscriptionButton => _t('subscriptionButton');
  String get quotaRemainingLabel => _t('quotaRemainingLabel');
  String get renewsMonday => _t('renewsMonday');
  String get historyLabel => _t('historyLabel');
  String get validUntilLabel => _t('validUntilLabel');
  String get foodPassIdLabel => _t('foodPassIdLabel');
  String get mealsUsedSuffix => _t('mealsUsedSuffix');
  String get planActive => _t('planActive');
  String get planInactive => _t('planInactive');

  String foodPassStatusLabel(FoodPassStatus status) =>
      _t('fpStatus_${status.name}');

  // Notifications / préférences / profil.
  String get notificationsTitle => _t('notificationsTitle');
  String get preferencesTitle => _t('preferencesTitle');
  String get notificationsEmpty => _t('notificationsEmpty');
  String get profileTitle => _t('profileTitle');
  String get profileIdLabel => _t('profileIdLabel');
  String get profileNotifications => _t('profileNotifications');
  String get profilePreferences => _t('profilePreferences');
  String get profileLanguage => _t('profileLanguage');
  String get profileHelp => _t('profileHelp');
  String get comingSoon => _t('comingSoon');

  String prefCategoryLabel(NotificationCategory c) => _t('prefLabel_${c.name}');
  String prefCategoryDesc(NotificationCategory c) => _t('prefDesc_${c.name}');

  // Réservation cantine.
  String get reservationConfirmedTitle => _t('reservationConfirmedTitle');
  String get reservationSubtitle => _t('reservationSubtitle');
  String get menuOfDay => _t('menuOfDay');
  String get cancelReservation => _t('cancelReservation');
  String get backToCanteen => _t('backToCanteen');
  String get cancelPossibleUntil => _t('cancelPossibleUntil');

  // Perte du Food Pass.
  String get lossTitle => _t('lossTitle');
  String get lossIrreversibleTitle => _t('lossIrreversibleTitle');
  String get lossIrreversibleBody => _t('lossIrreversibleBody');
  String get lossReasonQuestion => _t('lossReasonQuestion');
  String get confirmLoss => _t('confirmLoss');
  String get declareLossButton => _t('declareLossButton');
  String get lossDeclared => _t('lossDeclared');
  String lossReasonLabel(LossReason r) => _t('lossReason_${r.name}');
}

const Map<String, Map<String, String>> _values = <String, Map<String, String>>{
  'fr': <String, String>{
    'appTitle': 'SUP2I FOOD',
    'navHome': 'Accueil',
    'navOrder': 'Commander',
    'navCanteen': 'Cantine',
    'navOrders': 'Commandes',
    'navProfile': 'Profil',
    'homeMessage': 'Écran d\'accueil — à venir (M3).',
    'orderMessage': 'Catalogue et commande — à venir (M3–M6).',
    'canteenMessage': 'Cantine et Food Pass — à venir (M8).',
    'ordersMessage': 'Historique et suivi — à venir (M6–M7).',
    'profileMessage': 'Profil étudiant — à venir.',
    'loginBrandTagline': 'Reconnu par l\'État',
    'loginTitle': 'Connectez-vous à votre compte',
    'loginSubtitle':
        'Vous pouvez obtenir votre compte auprès de l\'administration.',
    'loginEmailLabel': 'Adresse e-mail',
    'loginEmailHint': 'Entrez votre e-mail',
    'loginPasswordLabel': 'Mot de passe',
    'loginPasswordHint': 'Au moins 8 caractères',
    'loginSubmit': 'Se connecter',
    'loginHelper': 'Votre compte est fourni par l\'administration.',
    'loginEmailRequired': 'Entrez votre e-mail.',
    'loginEmailInvalid': 'Format d\'e-mail invalide.',
    'loginPasswordRequired': 'Entrez votre mot de passe.',
    'loginShowPassword': 'Afficher le mot de passe',
    'loginHidePassword': 'Masquer le mot de passe',
    'profileLogout': 'Se déconnecter',
    'errUnauthorized': 'E-mail ou mot de passe incorrect.',
    'errAccountBlocked':
        'Votre compte est bloqué. Contactez l\'administration.',
    'errAccountSuspended':
        'Votre compte est suspendu. Contactez l\'administration.',
    'errRateLimited': 'Trop de tentatives. Réessayez dans un moment.',
    'errNetwork': 'Connexion impossible. Vérifiez votre réseau.',
    'errGeneric': 'Une erreur est survenue. Réessayez.',
    'catalogueAll': 'Tous',
    'catalogueEmpty': 'Aucun produit disponible pour le moment.',
    'retry': 'Réessayer',
    'productUnavailable': 'Indisponible',
    'addToCartComingSoon': 'Ajout au panier — à venir (M4).',
    'addToCart': 'Ajouter au panier',
    'allergensLabel': 'Allergènes',
    'minutesSuffix': 'min',
    'optionIncluded': 'Inclus',
    'cartTitle': 'Mon Panier',
    'cartEmptyTitle': 'Votre panier est vide',
    'cartEmptyHint': 'Ajoutez des produits pour commencer.',
    'discoverMenu': 'Découvrir le menu',
    'subtotalLabel': 'Sous-total',
    'totalLabel': 'Total',
    'totalIndicativeNote': 'Total indicatif — confirmé à la commande',
    'checkout': 'Commander',
    'checkoutComingSoon': 'Commande — à venir (M6).',
    'addedToCart': 'Ajouté au panier',
    'pickupSlotLabel': 'Créneau de retrait',
    'chooseSlot': 'Choisir un créneau',
    'noSlotSelected': 'Aucun créneau sélectionné',
    'slotAvailable': 'Disponible',
    'slotAlmostFull': 'Presque complet',
    'slotFull': 'Complet',
    'slotClosed': 'Fermé',
    'errMaxOrders': 'Vous avez atteint la limite de commandes actives.',
    'errInvalidOrderStatus': 'Action impossible à ce stade de la commande.',
    'errSlotFull': 'Ce créneau est complet.',
    'errSlotClosed': 'Ce créneau est fermé.',
    'paymentSheetTitle': 'Paiement',
    'paymentCash': 'Espèces (au comptoir)',
    'paymentCardTpe': 'Carte — TPE (au comptoir)',
    'paymentNote':
        'Le paiement s\'effectue au comptoir. L\'application ne confirme jamais le paiement.',
    'confirmOrder': 'Confirmer la commande',
    'orderNumberLabel': 'Numéro',
    'presentAtCounter': 'Présentez ce numéro au comptoir',
    'yourQr': 'Votre QR',
    'cancelOrder': 'Annuler la commande',
    'tlPaymentConfirmed': 'Paiement confirmé',
    'tlOrderReceived': 'Commande reçue',
    'tlPreparing': 'En préparation',
    'tlOrderReady': 'Votre commande est prête',
    'ordersEmpty': 'Aucune commande pour le moment.',
    'refresh': 'Actualiser',
    'orderReadyTitle': 'Votre commande est prête !',
    'queueAheadSuffix': 'commandes avant la vôtre',
    'etaLabel': 'Temps d\'attente estimé',
    'status_draft': 'Brouillon',
    'status_created': 'Créée',
    'status_awaitingPayment': 'En attente de paiement',
    'status_paid': 'Payée',
    'status_queued': 'En file',
    'status_preparing': 'En préparation',
    'status_ready': 'Prête',
    'status_collected': 'Retirée',
    'status_completed': 'Terminée',
    'status_cancelled': 'Annulée',
    'status_expired': 'Expirée',
    'status_refunded': 'Remboursée',
    'status_noShow': 'Non retirée',
    'homeWelcome': 'Bienvenue chez SUP2I FOOD',
    'homeSearchHint': 'Rechercher des produits',
    'homeFavorites': 'Nos coups de cœur',
    'homeCategories': 'Nos catégories',
    'homeProducts': 'Nos produits',
    'seeMore': 'Voir plus',
    'foodPassPageTitle': 'Food Pass',
    'subscriptionPageTitle': 'Mon abonnement',
    'foodPassButton': 'Votre Food Pass',
    'subscriptionButton': 'Mon abonnement Cantine',
    'quotaRemainingLabel': 'repas restants cette semaine',
    'renewsMonday': 'Se renouvelle chaque lundi',
    'historyLabel': 'Historique',
    'validUntilLabel': 'Valide jusqu\'au',
    'foodPassIdLabel': 'ID',
    'mealsUsedSuffix': 'repas utilisés',
    'fpStatus_active': 'Active',
    'fpStatus_blocked': 'Bloqué',
    'fpStatus_lost': 'Perdu',
    'fpStatus_expired': 'Expiré',
    'fpStatus_revoked': 'Révoqué',
    'planActive': 'Actif',
    'planInactive': 'Inactif',
    'notificationsTitle': 'Notifications',
    'preferencesTitle': 'Préférences',
    'notificationsEmpty': 'Aucune notification.',
    'profileTitle': 'Mon Profil',
    'profileIdLabel': 'ID étudiant',
    'profileNotifications': 'Notifications',
    'profilePreferences': 'Préférences de notifications',
    'profileLanguage': 'Langue',
    'profileHelp': 'Aide et support',
    'prefLabel_transactional': 'Transactionnel',
    'prefDesc_transactional': 'Statut de commande, paiement, retrait',
    'prefLabel_canteen': 'Cantine',
    'prefDesc_canteen': 'Quota, réservation, Food Pass',
    'prefLabel_promotions': 'Promotions',
    'prefDesc_promotions': 'Offres et réductions',
    'prefLabel_marketing': 'Marketing',
    'prefDesc_marketing': 'Actualités SUP2I FOOD',
    'comingSoon': 'Bientôt disponible',
    'reservationConfirmedTitle': 'Réservation confirmée',
    'reservationSubtitle': 'Votre repas vous attend à la cantine.',
    'menuOfDay': 'Menu du jour',
    'cancelReservation': 'Annuler la réservation',
    'backToCanteen': 'Retour à la cantine',
    'cancelPossibleUntil': 'Annulation possible jusqu\'à',
    'lossTitle': 'Perte de mon Food Pass',
    'lossIrreversibleTitle': 'Action irréversible',
    'lossIrreversibleBody':
        'Votre ancien QR sera invalidé immédiatement. Abonnement, quota et historique sont conservés.',
    'lossReasonQuestion': 'Pourquoi déclarez-vous la perte ?',
    'confirmLoss': 'Confirmer la perte',
    'declareLossButton': 'Déclarer la perte',
    'lossDeclared': 'Perte déclarée',
    'lossReason_damaged': 'Carte endommagée',
    'lossReason_stolen': 'Carte volée',
    'lossReason_lost': 'Carte perdue',
  },
  'en': <String, String>{
    'appTitle': 'SUP2I FOOD',
    'navHome': 'Home',
    'navOrder': 'Order',
    'navCanteen': 'Canteen',
    'navOrders': 'Orders',
    'navProfile': 'Profile',
    'homeMessage': 'Home screen — coming soon (M3).',
    'orderMessage': 'Catalog and ordering — coming soon (M3–M6).',
    'canteenMessage': 'Canteen and Food Pass — coming soon (M8).',
    'ordersMessage': 'History and tracking — coming soon (M6–M7).',
    'profileMessage': 'Student profile — coming soon.',
    'loginBrandTagline': 'State-recognized',
    'loginTitle': 'Log in to your account',
    'loginSubtitle': 'You can get your account from the administration.',
    'loginEmailLabel': 'Email address',
    'loginEmailHint': 'Enter your email',
    'loginPasswordLabel': 'Password',
    'loginPasswordHint': 'At least 8 characters',
    'loginSubmit': 'Sign in',
    'loginHelper': 'Your account is provided by the administration.',
    'loginEmailRequired': 'Enter your email.',
    'loginEmailInvalid': 'Invalid email format.',
    'loginPasswordRequired': 'Enter your password.',
    'loginShowPassword': 'Show password',
    'loginHidePassword': 'Hide password',
    'profileLogout': 'Log out',
    'errUnauthorized': 'Incorrect email or password.',
    'errAccountBlocked': 'Your account is blocked. Contact the administration.',
    'errAccountSuspended':
        'Your account is suspended. Contact the administration.',
    'errRateLimited': 'Too many attempts. Try again shortly.',
    'errNetwork': 'Unable to connect. Check your network.',
    'errGeneric': 'Something went wrong. Please try again.',
    'catalogueAll': 'All',
    'catalogueEmpty': 'No products available right now.',
    'retry': 'Retry',
    'productUnavailable': 'Unavailable',
    'addToCartComingSoon': 'Add to cart — coming soon (M4).',
    'addToCart': 'Add to cart',
    'allergensLabel': 'Allergens',
    'minutesSuffix': 'min',
    'optionIncluded': 'Included',
    'cartTitle': 'My Cart',
    'cartEmptyTitle': 'Your cart is empty',
    'cartEmptyHint': 'Add products to get started.',
    'discoverMenu': 'Browse the menu',
    'subtotalLabel': 'Subtotal',
    'totalLabel': 'Total',
    'totalIndicativeNote': 'Indicative total — confirmed at checkout',
    'checkout': 'Order',
    'checkoutComingSoon': 'Checkout — coming soon (M6).',
    'addedToCart': 'Added to cart',
    'pickupSlotLabel': 'Pickup slot',
    'chooseSlot': 'Choose a slot',
    'noSlotSelected': 'No slot selected',
    'slotAvailable': 'Available',
    'slotAlmostFull': 'Almost full',
    'slotFull': 'Full',
    'slotClosed': 'Closed',
    'errMaxOrders': 'You have reached the active orders limit.',
    'errInvalidOrderStatus': 'This action is not possible at this stage.',
    'errSlotFull': 'This slot is full.',
    'errSlotClosed': 'This slot is closed.',
    'paymentSheetTitle': 'Payment',
    'paymentCash': 'Cash (at counter)',
    'paymentCardTpe': 'Card — POS (at counter)',
    'paymentNote':
        'Payment is made at the counter. The app never confirms payment.',
    'confirmOrder': 'Confirm order',
    'orderNumberLabel': 'Number',
    'presentAtCounter': 'Show this number at the counter',
    'yourQr': 'Your QR',
    'cancelOrder': 'Cancel order',
    'tlPaymentConfirmed': 'Payment confirmed',
    'tlOrderReceived': 'Order received',
    'tlPreparing': 'Preparing',
    'tlOrderReady': 'Your order is ready',
    'ordersEmpty': 'No orders yet.',
    'refresh': 'Refresh',
    'orderReadyTitle': 'Your order is ready!',
    'queueAheadSuffix': 'orders ahead of you',
    'etaLabel': 'Estimated wait',
    'status_draft': 'Draft',
    'status_created': 'Created',
    'status_awaitingPayment': 'Awaiting payment',
    'status_paid': 'Paid',
    'status_queued': 'Queued',
    'status_preparing': 'Preparing',
    'status_ready': 'Ready',
    'status_collected': 'Collected',
    'status_completed': 'Completed',
    'status_cancelled': 'Cancelled',
    'status_expired': 'Expired',
    'status_refunded': 'Refunded',
    'status_noShow': 'No-show',
    'homeWelcome': 'Welcome to SUP2I FOOD',
    'homeSearchHint': 'Search products',
    'homeFavorites': 'Our favourites',
    'homeCategories': 'Categories',
    'homeProducts': 'Products',
    'seeMore': 'See more',
    'foodPassPageTitle': 'Food Pass',
    'subscriptionPageTitle': 'My subscription',
    'foodPassButton': 'Your Food Pass',
    'subscriptionButton': 'My canteen subscription',
    'quotaRemainingLabel': 'meals left this week',
    'renewsMonday': 'Renews every Monday',
    'historyLabel': 'History',
    'validUntilLabel': 'Valid until',
    'foodPassIdLabel': 'ID',
    'mealsUsedSuffix': 'meals used',
    'fpStatus_active': 'Active',
    'fpStatus_blocked': 'Blocked',
    'fpStatus_lost': 'Lost',
    'fpStatus_expired': 'Expired',
    'fpStatus_revoked': 'Revoked',
    'planActive': 'Active',
    'planInactive': 'Inactive',
    'notificationsTitle': 'Notifications',
    'preferencesTitle': 'Preferences',
    'notificationsEmpty': 'No notifications.',
    'profileTitle': 'My Profile',
    'profileIdLabel': 'Student ID',
    'profileNotifications': 'Notifications',
    'profilePreferences': 'Notification preferences',
    'profileLanguage': 'Language',
    'profileHelp': 'Help & support',
    'prefLabel_transactional': 'Transactional',
    'prefDesc_transactional': 'Order status, payment, pickup',
    'prefLabel_canteen': 'Canteen',
    'prefDesc_canteen': 'Quota, reservation, Food Pass',
    'prefLabel_promotions': 'Promotions',
    'prefDesc_promotions': 'Offers and discounts',
    'prefLabel_marketing': 'Marketing',
    'prefDesc_marketing': 'SUP2I FOOD news',
    'comingSoon': 'Coming soon',
    'reservationConfirmedTitle': 'Reservation confirmed',
    'reservationSubtitle': 'Your meal is waiting at the canteen.',
    'menuOfDay': 'Menu of the day',
    'cancelReservation': 'Cancel reservation',
    'backToCanteen': 'Back to canteen',
    'cancelPossibleUntil': 'Cancellation possible until',
    'lossTitle': 'Report my Food Pass loss',
    'lossIrreversibleTitle': 'Irreversible action',
    'lossIrreversibleBody':
        'Your old QR will be invalidated immediately. Subscription, quota and history are kept.',
    'lossReasonQuestion': 'Why are you reporting the loss?',
    'confirmLoss': 'Confirm loss',
    'declareLossButton': 'Report loss',
    'lossDeclared': 'Loss reported',
    'lossReason_damaged': 'Damaged card',
    'lossReason_stolen': 'Stolen card',
    'lossReason_lost': 'Lost card',
  },
  'ar': <String, String>{
    'appTitle': 'SUP2I FOOD',
    'navHome': 'الرئيسية',
    'navOrder': 'اطلب',
    'navCanteen': 'المقصف',
    'navOrders': 'طلباتي',
    'navProfile': 'حسابي',
    'homeMessage': 'الشاشة الرئيسية — قريبًا (M3).',
    'orderMessage': 'القائمة والطلب — قريبًا (M3–M6).',
    'canteenMessage': 'المقصف وبطاقة الطعام — قريبًا (M8).',
    'ordersMessage': 'السجل والتتبع — قريبًا (M6–M7).',
    'profileMessage': 'الملف الشخصي للطالب — قريبًا.',
    'loginBrandTagline': 'معترف بها من الدولة',
    'loginTitle': 'سجّل الدخول إلى حسابك',
    'loginSubtitle': 'يمكنك الحصول على حسابك من الإدارة.',
    'loginEmailLabel': 'البريد الإلكتروني',
    'loginEmailHint': 'أدخل بريدك الإلكتروني',
    'loginPasswordLabel': 'كلمة المرور',
    'loginPasswordHint': '8 أحرف على الأقل',
    'loginSubmit': 'تسجيل الدخول',
    'loginHelper': 'حسابك مُقدَّم من الإدارة.',
    'loginEmailRequired': 'أدخل بريدك الإلكتروني.',
    'loginEmailInvalid': 'صيغة البريد الإلكتروني غير صحيحة.',
    'loginPasswordRequired': 'أدخل كلمة المرور.',
    'loginShowPassword': 'إظهار كلمة المرور',
    'loginHidePassword': 'إخفاء كلمة المرور',
    'profileLogout': 'تسجيل الخروج',
    'errUnauthorized': 'البريد الإلكتروني أو كلمة المرور غير صحيحة.',
    'errAccountBlocked': 'حسابك محظور. يرجى التواصل مع الإدارة.',
    'errAccountSuspended': 'حسابك موقوف. يرجى التواصل مع الإدارة.',
    'errRateLimited': 'محاولات كثيرة جدًا. حاول مرة أخرى بعد قليل.',
    'errNetwork': 'تعذّر الاتصال. تحقق من شبكتك.',
    'errGeneric': 'حدث خطأ ما. حاول مرة أخرى.',
    'catalogueAll': 'الكل',
    'catalogueEmpty': 'لا توجد منتجات متاحة حاليًا.',
    'retry': 'إعادة المحاولة',
    'productUnavailable': 'غير متوفر',
    'addToCartComingSoon': 'الإضافة إلى السلة — قريبًا (M4).',
    'addToCart': 'أضف إلى السلة',
    'allergensLabel': 'مسببات الحساسية',
    'minutesSuffix': 'دقيقة',
    'optionIncluded': 'مشمول',
    'cartTitle': 'سلتي',
    'cartEmptyTitle': 'سلتك فارغة',
    'cartEmptyHint': 'أضف منتجات للبدء.',
    'discoverMenu': 'تصفّح القائمة',
    'subtotalLabel': 'المجموع الفرعي',
    'totalLabel': 'المجموع',
    'totalIndicativeNote': 'مجموع تقديري — يُؤكَّد عند الطلب',
    'checkout': 'اطلب',
    'checkoutComingSoon': 'الطلب — قريبًا (M6).',
    'addedToCart': 'أُضيف إلى السلة',
    'pickupSlotLabel': 'موعد الاستلام',
    'chooseSlot': 'اختر موعدًا',
    'noSlotSelected': 'لم يتم اختيار موعد',
    'slotAvailable': 'متاح',
    'slotAlmostFull': 'شبه ممتلئ',
    'slotFull': 'ممتلئ',
    'slotClosed': 'مغلق',
    'errMaxOrders': 'لقد بلغت الحد الأقصى للطلبات النشطة.',
    'errInvalidOrderStatus': 'لا يمكن تنفيذ هذا الإجراء في هذه المرحلة.',
    'errSlotFull': 'هذا الموعد ممتلئ.',
    'errSlotClosed': 'هذا الموعد مغلق.',
    'paymentSheetTitle': 'الدفع',
    'paymentCash': 'نقدًا (عند الكاونتر)',
    'paymentCardTpe': 'بطاقة — TPE (عند الكاونتر)',
    'paymentNote': 'يتم الدفع عند الكاونتر. لا يؤكّد التطبيق الدفع أبدًا.',
    'confirmOrder': 'تأكيد الطلب',
    'orderNumberLabel': 'الرقم',
    'presentAtCounter': 'اعرض هذا الرقم عند الكاونتر',
    'yourQr': 'رمز الاستلام',
    'cancelOrder': 'إلغاء الطلب',
    'tlPaymentConfirmed': 'تم تأكيد الدفع',
    'tlOrderReceived': 'تم استلام الطلب',
    'tlPreparing': 'قيد التحضير',
    'tlOrderReady': 'طلبك جاهز',
    'ordersEmpty': 'لا توجد طلبات بعد.',
    'refresh': 'تحديث',
    'orderReadyTitle': 'طلبك جاهز!',
    'queueAheadSuffix': 'طلبات قبلك',
    'etaLabel': 'مدة الانتظار المقدّرة',
    'status_draft': 'مسودة',
    'status_created': 'أُنشئت',
    'status_awaitingPayment': 'بانتظار الدفع',
    'status_paid': 'مدفوعة',
    'status_queued': 'في الطابور',
    'status_preparing': 'قيد التحضير',
    'status_ready': 'جاهزة',
    'status_collected': 'مُستلمة',
    'status_completed': 'مكتملة',
    'status_cancelled': 'ملغاة',
    'status_expired': 'منتهية',
    'status_refunded': 'مُستردة',
    'status_noShow': 'لم تُستلم',
    'homeWelcome': 'مرحبًا بك في SUP2I FOOD',
    'homeSearchHint': 'ابحث عن المنتجات',
    'homeFavorites': 'مختاراتنا',
    'homeCategories': 'الفئات',
    'homeProducts': 'المنتجات',
    'seeMore': 'عرض المزيد',
    'foodPassPageTitle': 'بطاقة الطعام',
    'subscriptionPageTitle': 'اشتراكي',
    'foodPassButton': 'بطاقة الطعام',
    'subscriptionButton': 'اشتراك المقصف',
    'quotaRemainingLabel': 'وجبات متبقية هذا الأسبوع',
    'renewsMonday': 'يتجدد كل يوم اثنين',
    'historyLabel': 'السجل',
    'validUntilLabel': 'صالحة حتى',
    'foodPassIdLabel': 'المعرّف',
    'mealsUsedSuffix': 'وجبات مستهلكة',
    'fpStatus_active': 'نشِطة',
    'fpStatus_blocked': 'محظورة',
    'fpStatus_lost': 'مفقودة',
    'fpStatus_expired': 'منتهية',
    'fpStatus_revoked': 'ملغاة',
    'planActive': 'نشِط',
    'planInactive': 'غير نشِط',
    'notificationsTitle': 'الإشعارات',
    'preferencesTitle': 'التفضيلات',
    'notificationsEmpty': 'لا توجد إشعارات.',
    'profileTitle': 'ملفي',
    'profileIdLabel': 'معرّف الطالب',
    'profileNotifications': 'الإشعارات',
    'profilePreferences': 'تفضيلات الإشعارات',
    'profileLanguage': 'اللغة',
    'profileHelp': 'المساعدة والدعم',
    'prefLabel_transactional': 'المعاملات',
    'prefDesc_transactional': 'حالة الطلب، الدفع، الاستلام',
    'prefLabel_canteen': 'المقصف',
    'prefDesc_canteen': 'الحصة، الحجز، بطاقة الطعام',
    'prefLabel_promotions': 'العروض',
    'prefDesc_promotions': 'العروض والتخفيضات',
    'prefLabel_marketing': 'التسويق',
    'prefDesc_marketing': 'أخبار SUP2I FOOD',
    'comingSoon': 'قريبًا',
    'reservationConfirmedTitle': 'تم تأكيد الحجز',
    'reservationSubtitle': 'وجبتك بانتظارك في المقصف.',
    'menuOfDay': 'قائمة اليوم',
    'cancelReservation': 'إلغاء الحجز',
    'backToCanteen': 'العودة إلى المقصف',
    'cancelPossibleUntil': 'الإلغاء ممكن حتى',
    'lossTitle': 'الإبلاغ عن فقدان بطاقتي',
    'lossIrreversibleTitle': 'إجراء لا رجعة فيه',
    'lossIrreversibleBody':
        'سيتم إبطال رمزك القديم فورًا. يتم الاحتفاظ بالاشتراك والحصة والسجل.',
    'lossReasonQuestion': 'لماذا تبلّغ عن الفقدان؟',
    'confirmLoss': 'تأكيد الفقدان',
    'declareLossButton': 'الإبلاغ عن الفقدان',
    'lossDeclared': 'تم الإبلاغ عن الفقدان',
    'lossReason_damaged': 'بطاقة تالفة',
    'lossReason_stolen': 'بطاقة مسروقة',
    'lossReason_lost': 'بطاقة مفقودة',
  },
};

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['fr', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Repli Material : fournit les libellés natifs (anglais) pour fr/ar/en,
/// à remplacer par `GlobalMaterialLocalizations` (flutter_localizations) en M2.
class _FallbackMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const _FallbackMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['fr', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      SynchronousFuture<MaterialLocalizations>(
        const DefaultMaterialLocalizations(),
      );

  @override
  bool shouldReload(_FallbackMaterialLocalizationsDelegate old) => false;
}

/// Repli Cupertino pour fr/ar/en (libellés natifs anglais en attendant M2).
class _FallbackCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const _FallbackCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['fr', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      SynchronousFuture<CupertinoLocalizations>(
        const DefaultCupertinoLocalizations(),
      );

  @override
  bool shouldReload(_FallbackCupertinoLocalizationsDelegate old) => false;
}

/// Repli Widgets pour fr/ar/en (la direction RTL réelle est appliquée par le
/// `builder` de `MaterialApp`, cf. `AppLocalizations.textDirection`).
class _FallbackWidgetsLocalizationsDelegate
    extends LocalizationsDelegate<WidgetsLocalizations> {
  const _FallbackWidgetsLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      const <String>['fr', 'ar', 'en'].contains(locale.languageCode);

  @override
  Future<WidgetsLocalizations> load(Locale locale) =>
      SynchronousFuture<WidgetsLocalizations>(
        const DefaultWidgetsLocalizations(),
      );

  @override
  bool shouldReload(_FallbackWidgetsLocalizationsDelegate old) => false;
}
