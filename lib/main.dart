import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/settings/application/settings_controller.dart';
import 'features/settings/data/settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Charge les préférences persistées (langue, thème) avant le premier rendu
  // pour éviter tout flash de thème/langue au démarrage.
  final store = await SharedPreferencesSettingsStore.create();
  final settings = SettingsController(store);
  await settings.load();
  runApp(Sup2iFoodApp(settings: settings));
}
