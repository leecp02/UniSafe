class HotlineItem {
  final String id;
  final String label;
  final String number;
  final String iconKey;

  const HotlineItem({
    required this.id,
    required this.label,
    required this.number,
    required this.iconKey,
  });

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'number': number,
      'iconKey': iconKey,
    };
  }

  factory HotlineItem.fromMap(String id, Map<String, dynamic> map) {
    return HotlineItem(
      id: id,
      label: (map['label'] ?? '').toString(),
      number: (map['number'] ?? '').toString(),
      iconKey: (map['iconKey'] ?? 'support').toString(),
    );
  }
}
