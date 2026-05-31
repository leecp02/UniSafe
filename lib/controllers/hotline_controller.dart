import '../models/hotline_item_model.dart';
import '../services/hotline_service.dart';

class HotlineController {
  final HotlineService service = HotlineService();

  Future<void> ensureDefaults() {
    return service.ensureDefaults();
  }

  Stream<List<HotlineItem>> watchHotlines() {
    return service.watchHotlines();
  }

  Future<void> addHotline({
    required String label,
    required String number,
    required String iconKey,
  }) async {
    final cleanLabel = label.trim();
    final cleanNumber = number.trim();
    if (cleanLabel.isEmpty || cleanNumber.isEmpty) {
      throw Exception('Label and number are required.');
    }

    await service.addHotline(
      label: cleanLabel,
      number: cleanNumber,
      iconKey: iconKey,
    );
  }

  Future<void> updateHotline({
    required HotlineItem item,
    required String label,
    required String number,
    required String iconKey,
  }) async {
    final cleanLabel = label.trim();
    final cleanNumber = number.trim();
    if (cleanLabel.isEmpty || cleanNumber.isEmpty) {
      throw Exception('Label and number are required.');
    }

    await service.upsertHotline(
      HotlineItem(
        id: item.id,
        label: cleanLabel,
        number: cleanNumber,
        iconKey: iconKey,
      ),
    );
  }

  Future<void> deleteHotline({
    required HotlineItem item,
  }) async {
    await service.deleteHotline(item.id);
  }
}
