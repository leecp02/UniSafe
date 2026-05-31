import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/hotline_item_model.dart';

class HotlineService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  static const List<HotlineItem> defaultHotlines = [
    HotlineItem(id: 'police', label: 'Police', number: '999', iconKey: 'police'),
    HotlineItem(
      id: 'ambulance_fire',
      label: 'Ambulance / Fire',
      number: '994',
      iconKey: 'hospital',
    ),
    HotlineItem(
      id: 'unimas_security',
      label: 'UNIMAS Security',
      number: '082-583999',
      iconKey: 'security',
    ),
    HotlineItem(
      id: 'talian_kasih',
      label: 'Talian Kasih (Social Welfare)',
      number: '15999',
      iconKey: 'support',
    ),
    HotlineItem(
      id: 'womens_aid',
      label: "Women's Aid Organisation",
      number: '03-30008858',
      iconKey: 'people',
    ),
  ];

  Future<void> ensureDefaults() async {
    final collection = firestore.collection('hotlines');
    final snapshot = await collection.limit(1).get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final batch = firestore.batch();
    for (final hotline in defaultHotlines) {
      batch.set(collection.doc(hotline.id), hotline.toMap());
    }
    await batch.commit();
  }

  Stream<List<HotlineItem>> watchHotlines() {
    return firestore.collection('hotlines').snapshots().map((snapshot) {
      final items = snapshot.docs
          .map((doc) => HotlineItem.fromMap(doc.id, doc.data()))
          .where((item) => item.label.isNotEmpty && item.number.isNotEmpty)
          .toList();

      items.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
      return items;
    });
  }

  Future<void> upsertHotline(HotlineItem hotline) async {
    await firestore.collection('hotlines').doc(hotline.id).set(hotline.toMap());
  }

  Future<void> addHotline({
    required String label,
    required String number,
    required String iconKey,
  }) async {
    await firestore.collection('hotlines').add({
      'label': label,
      'number': number,
      'iconKey': iconKey,
    });
  }

  Future<void> deleteHotline(String id) async {
    await firestore.collection('hotlines').doc(id).delete();
  }
}
