/// Formatage de la devise — règle gelée : `35,00 DH`
/// (virgule décimale, 2 décimales, suffixe « DH », jamais « MAD »).
///
/// Les montants sont manipulés en **centimes entiers** (minor units) pour
/// éviter les erreurs de flottant. Le Mobile ne recalcule jamais un prix comme
/// autorité : il ne fait que formater ce que le serveur renvoie.
abstract final class Money {
  static const String currencySuffix = 'DH';

  /// Formate un montant en centimes : `4000` → `40,00 DH`, `720` → `7,20 DH`.
  static String format(int cents) {
    final sign = cents < 0 ? '-' : '';
    final abs = cents.abs();
    final whole = abs ~/ 100;
    final frac = (abs % 100).toString().padLeft(2, '0');
    return '$sign$whole,$frac $currencySuffix';
  }
}
