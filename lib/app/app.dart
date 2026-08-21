import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/application/auth_controller.dart';
import '../features/auth/data/mock_auth_repository.dart';
import '../features/cart/application/cart_controller.dart';
import '../features/favorites/application/favorites_controller.dart';
import '../features/orders/data/mock_order_repository.dart';
import '../features/orders/data/order_repository.dart';
import '../features/settings/application/settings_controller.dart';
import '../l10n/app_localizations.dart';
import 'auth_gate.dart';
import 'auth_scope.dart';
import 'cart_scope.dart';
import 'favorites_scope.dart';
import 'orders_scope.dart';
import 'settings_scope.dart';

/// Racine de l'application SUP2I FOOD.
class Sup2iFoodApp extends StatefulWidget {
  const Sup2iFoodApp({super.key});

  @override
  State<Sup2iFoodApp> createState() => _Sup2iFoodAppState();
}

class _Sup2iFoodAppState extends State<Sup2iFoodApp> {
  // Repository mock tant qu'aucun backend/OpenAPI n'est disponible (M2).
  final AuthController _auth = AuthController(const MockAuthRepository());
  final CartController _cart = CartController();
  final OrderRepository _orders = MockOrderRepository();
  final FavoritesController _favorites = FavoritesController();
  final SettingsController _settings = SettingsController();

  @override
  void dispose() {
    _auth.dispose();
    _cart.dispose();
    _favorites.dispose();
    _settings.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SettingsScope(
      controller: _settings,
      child: AuthScope(
        controller: _auth,
        child: CartScope(
          controller: _cart,
          child: OrdersScope(
            repository: _orders,
            child: FavoritesScope(
              controller: _favorites,
              child: ListenableBuilder(
                listenable: _settings,
                builder: (context, _) => MaterialApp(
                  onGenerateTitle: (context) =>
                      AppLocalizations.of(context).appTitle,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: _settings.themeMode,
                  locale: _settings.locale,
                  supportedLocales: AppLocalizations.supportedLocales,
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  // Direction RTL pour l'arabe (delegates globaux -> M2).
                  builder: (context, child) => Directionality(
                    textDirection: AppLocalizations.of(context).textDirection,
                    child: child!,
                  ),
                  home: const AuthGate(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
