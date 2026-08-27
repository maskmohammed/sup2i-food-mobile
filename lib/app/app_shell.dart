import 'package:flutter/material.dart';

import '../features/canteen/presentation/canteen_page.dart';
import '../features/catalogue/presentation/catalogue_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/orders/presentation/orders_list_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../l10n/app_localizations.dart';
import 'auth_guard.dart';
import 'auth_scope.dart';

/// Coquille de l'application : bottom nav gelée à 5 onglets
/// (Accueil / Commander / Cantine / Commandes / Profil).
///
/// [IndexedStack] conserve l'état et la pile de chaque onglet en mémoire lors
/// des changements. Le routing déclaratif (go_router) sera introduit en M2
/// avec l'auth et les deep-links ; inutile de sur-outiller la nav ici.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    CataloguePage(),
    CanteenPage(),
    OrdersListPage(),
    ProfilePage(),
  ];

  /// Onglets protégés (connexion requise) : Cantine(2), Commandes(3), Profil(4).
  /// Accueil(0) et Commander(1) restent libres en mode invité.
  static bool _requiresAuth(int index) => index >= 2;

  void _onSelect(int index) {
    if (index == _index) return;
    // Mur de connexion AVANT toute navigation vers un onglet protégé.
    if (_requiresAuth(index)) {
      final loc = AppLocalizations.of(context);
      if (!AuthGuard.require(context, message: loc.loginWallTabMessage)) return;
    }
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

    // Après une déconnexion, si l'onglet actif est protégé, on ramène l'invité
    // sur Accueil (règle centralisée, pas dupliquée dans le Profil).
    final authed = AuthScope.of(context).isAuthenticated;
    if (!authed && _requiresAuth(_index)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !AuthScope.of(context).isAuthenticated) {
          setState(() => _index = 0);
        }
      });
    }

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _onSelect,
        destinations: <NavigationDestination>[
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: loc.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_bag_outlined),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: loc.navOrder,
          ),
          NavigationDestination(
            icon: const Icon(Icons.restaurant_outlined),
            selectedIcon: const Icon(Icons.restaurant),
            label: loc.navCanteen,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: loc.navOrders,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: loc.navProfile,
          ),
        ],
      ),
    );
  }
}
