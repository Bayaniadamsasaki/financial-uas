import 'dart:convert';

class ScheduledBill {
  const ScheduledBill({
    required this.type,
    required this.amount,
    required this.dueDateIso,
    required this.reminderEnabled,
  });

  final String type;
  final int amount;
  final String dueDateIso;
  final bool reminderEnabled;

  DateTime? get dueDate => DateTime.tryParse(dueDateIso);

  ScheduledBill copyWith({
    String? type,
    int? amount,
    String? dueDateIso,
    bool? reminderEnabled,
  }) {
    return ScheduledBill(
      type: type ?? this.type,
      amount: amount ?? this.amount,
      dueDateIso: dueDateIso ?? this.dueDateIso,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    );
  }

  factory ScheduledBill.fromJson(Map<String, dynamic> jsonData) {
    final dynamic amountRaw = jsonData['amount'];
    final dynamic reminderRaw = jsonData['reminderEnabled'];

    return ScheduledBill(
      type: (jsonData['type'] ?? '').toString(),
      amount: amountRaw is int
          ? amountRaw
          : int.tryParse((amountRaw ?? '0').toString()) ?? 0,
      dueDateIso: (jsonData['dueDateIso'] ?? '').toString(),
      reminderEnabled: reminderRaw is bool
          ? reminderRaw
          : (reminderRaw ?? 'false').toString().toLowerCase() == 'true',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'amount': amount,
      'dueDateIso': dueDateIso,
      'reminderEnabled': reminderEnabled,
    };
  }

  static String encode(List<ScheduledBill> items) {
    return json.encode(
      items.map<Map<String, dynamic>>((item) => item.toMap()).toList(),
    );
  }

  static List<ScheduledBill> decode(String encodedItems) {
    final List<dynamic> decodedList = json.decode(encodedItems) as List<dynamic>;
    return decodedList
        .whereType<Map<String, dynamic>>()
        .map(ScheduledBill.fromJson)
        .toList();
  }
}
