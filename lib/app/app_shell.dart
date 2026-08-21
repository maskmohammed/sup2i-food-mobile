import 'package:flutter/material.dart';

import '../features/canteen/presentation/canteen_page.dart';
import '../features/catalogue/presentation/catalogue_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/orders/presentation/orders_list_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../l10n/app_localizations.dart';

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

  void _onSelect(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations loc = AppLocalizations.of(context);

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
