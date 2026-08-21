import '../domain/time_slot.dart';

/// Contrat d'accès aux créneaux de retrait (autorité serveur).
abstract interface class SlotRepository {
  Future<List<TimeSlot>> slots();
}

/// Créneaux mock (M4). États variés pour exercer l'UI.
class MockSlotRepository implements SlotRepository {
  const MockSlotRepository({this.latency = const Duration(milliseconds: 300)});

  final Duration latency;

  @override
  Future<List<TimeSlot>> slots() async {
    await Future<void>.delayed(latency);
    return const <TimeSlot>[
      TimeSlot(id: 's1', label: '12h00 - 12h15', status: SlotStatus.available),
      TimeSlot(id: 's2', label: '12h15 - 12h30', status: SlotStatus.available),
      TimeSlot(id: 's3', label: '12h30 - 12h45', status: SlotStatus.almostFull),
      TimeSlot(id: 's4', label: '12h45 - 13h00', status: SlotStatus.full),
      TimeSlot(id: 's5', label: '13h00 - 13h15', status: SlotStatus.available),
    ];
  }
}
