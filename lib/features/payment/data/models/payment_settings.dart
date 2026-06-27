class PaymentSettings {
  double paymentAmount;
  int dueDay;
  double lateFee;
  bool autoGenerate;
  DateTime? lastGenerated;

  PaymentSettings({
    this.paymentAmount = 10.0,
    this.dueDay = 1,
    this.lateFee = 5.0,
    this.autoGenerate = false,
    this.lastGenerated,
  });

  Map<String, dynamic> toJson() => {
    'paymentAmount': paymentAmount,
    'dueDay': dueDay,
    'lateFee': lateFee,
    'autoGenerate': autoGenerate,
    'lastGenerated': lastGenerated?.toIso8601String(),
  };

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String) return DateTime.tryParse(v);
      return null;
    }
    return PaymentSettings(
      paymentAmount: (json['paymentAmount'] as num?)?.toDouble() ?? 10.0,
      dueDay: (json['dueDay'] as num?)?.toInt() ?? 1,
      lateFee: (json['lateFee'] as num?)?.toDouble() ?? 5.0,
      autoGenerate: json['autoGenerate'] as bool? ?? false,
      lastGenerated: parseDate(json['lastGenerated']),
    );
  }

  bool get hasGeneratedThisMonth {
    if (lastGenerated == null) return false;
    final now = DateTime.now();
    return lastGenerated!.month == now.month && lastGenerated!.year == now.year;
  }
}
