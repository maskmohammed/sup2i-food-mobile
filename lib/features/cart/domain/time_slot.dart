/// État d'un créneau de retrait (source serveur — jamais calculé localement).
enum SlotStatus { available, almostFull, full, closed }

/// Créneau horaire de retrait.
class TimeSlot {
  const TimeSlot({required this.id, required this.label, required this.status});

  final String id;
  final String label;
  final SlotStatus status;

  /// Sélectionnable seulement si de la place reste (jamais `full`/`closed`).
  bool get selectable =>
      status == SlotStatus.available || status == SlotStatus.almostFull;
}
