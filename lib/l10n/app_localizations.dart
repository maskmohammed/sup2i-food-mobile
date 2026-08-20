import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
