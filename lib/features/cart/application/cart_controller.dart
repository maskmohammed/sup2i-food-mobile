import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../domain/cart_line.dart';
import '../domain/time_slot.dart';

/// Panier partagé (app-level via CartScope).
///
/// Le [subtotalCents] est **indicatif** : le total définitif est calculé et
/// confirmé par le serveur à la création de commande (M6). Le Mobile ne fait
/// jamais autorité sur le prix.
class CartController extends ChangeNotifier {
  final List<CartLine> _lines = <CartLine>[];
  TimeSlot? _slot;

  List<CartLine> get lines => List<CartLine>.unmodifiable(_lines);
  bool get isEmpty => _lines.isEmpty;
  int get itemCount => _lines.fold(0, (sum, l) => sum + l.quantity);
  int get subtotalCents => _lines.fold(0, (sum, l) => sum + l.lineTotalCents);
  TimeSlot? get slot => _slot;

  void addItem({
    required String productId,
    required String name,
    required int unitPriceCents,
    int quantity = 1,
    String? optionsLabel,
  }) {
    final id = '$productId|${optionsLabel ?? ''}';
    final index = _lines.indexWhere((l) => l.id == id);
    if (index >= 0) {
      _lines[index] = _lines[index].copyWith(
        quantity: _lines[index].quantity + quantity,
      );
    } else {
      _lines.add(
        CartLine(
          id: id,
          productId: productId,
          name: name,
          unitPriceCents: unitPriceCents,
          quantity: quantity,
          optionsLabel: optionsLabel,
        ),
      );
    }
    notifyListeners();
  }

  void increment(String lineId) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index < 0) return;
    _lines[index] = _lines[index].copyWith(
      quantity: _lines[index].quantity + 1,
    );
    notifyListeners();
  }

  void decrement(String lineId) {
    final index = _lines.indexWhere((l) => l.id == lineId);
    if (index < 0) return;
    final quantity = _lines[index].quantity - 1;
    if (quantity <= 0) {
      _lines.removeAt(index);
    } else {
      _lines[index] = _lines[index].copyWith(quantity: quantity);
    }
    notifyListeners();
  }

  void remove(String lineId) {
    _lines.removeWhere((l) => l.id == lineId);
    notifyListeners();
  }

  void selectSlot(TimeSlot slot) {
    _slot = slot;
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _slot = null;
    notifyListeners();
  }
}
