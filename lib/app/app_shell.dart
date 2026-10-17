import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/canteen/presentation/canteen_page.dart';
import '../features/catalogue/presentation/catalogue_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/orders/presentation/orders_list_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../l10n/app_localizations.dart';

/// Final authenticated mobile shell.
///
/// Entry authentication is handled by AuthGate. Every tab in this shell is
/// therefore an authenticated student experience.
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
    OrdersListPage(),
    CanteenPage(),
    ProfilePage(),
  ];

  void _onSelect(int index) {
    if (index == _index) return;
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.neutral0,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Color(0x14161B5C),
              blurRadius: 22,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            key: const Key('main_bottom_navigation'),
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            destinations: <NavigationDestination>[
              NavigationDestination(
                icon: const Icon(Icons.home_rounded),
                selectedIcon: const Icon(Icons.home_rounded),
                label: loc.navHome,
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_menu_rounded),
                selectedIcon: const Icon(Icons.restaurant_menu_rounded),
                label: loc.navOrder,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                selectedIcon: const Icon(Icons.receipt_long_rounded),
                label: loc.navOrders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.restaurant_outlined),
                selectedIcon: const Icon(Icons.restaurant_rounded),
                label: loc.navCanteen,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: loc.navProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
