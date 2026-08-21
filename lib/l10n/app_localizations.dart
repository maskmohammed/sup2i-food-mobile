import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../core/error/api_codes.dart';
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

  /// Libellé localisé d'un statut de commande.
  String orderStatusLabel(OrderStatus status) => _t('status_${status.name}');

  // Accueil.
  String get homeWelcome => _t('homeWelcome');
  String get homeSearchHint => _t('homeSearchHint');
  String get homeFavorites => _t('homeFavorites');
  String get homeCategories => _t('homeCategories');
  String get homeProducts => _t('homeProducts');
  String get seeMore => _t('seeMore');
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
