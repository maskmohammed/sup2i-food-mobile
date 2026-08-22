import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';

/// Configuration commune à tous les tests (auto-découverte par flutter_test).
///
/// - Désactive la récupération réseau de `google_fonts` : pas de réseau en test,
///   et rendu déterministe (indispensable pour les golden tests).
/// - Les polices absentes des assets retombent sur la police par défaut du
///   harnais ; l'erreur `google_fonts` correspondante est ignorée (sans réseau
///   ni .ttf embarqués, elle est attendue et sans conséquence sur le rendu).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  GoogleFonts.config.allowRuntimeFetching = false;

  final defaultOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final msg = details.exceptionAsString().toLowerCase();
    if (msg.contains('google') && msg.contains('font')) return;
    defaultOnError?.call(details);
  };

  await testMain();
}
