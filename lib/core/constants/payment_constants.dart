class PaymentConstants {
  // Payment amounts and frequencies
  static const double monthlyPaymentAmount = 10.0;
  static const double weeklyPaymentAmount = 2.5;
  static const double yearlyPaymentAmount = 120.0;

  // Payment due dates
  static const int monthlyDueDay = 1; // 1st of every month
  static const int weeklyDueDay = 1; // Monday (1 = Monday, 7 = Sunday)
  static const int yearlyDueMonth = 1; // January
  static const int yearlyDueDay = 1; // 1st of January

  // Payment cycles
  static const String cycleMonthly = 'monthly';
  static const String cycleWeekly = 'weekly';
  static const String cycleYearly = 'yearly';

  // Payment methods
  static const String methodCash = 'cash';
  static const String methodTeleBirr = 'telebirr';
  static const String methodMpesa = 'mpesa';
  static const String methodBankTransfer = 'bank_transfer';

  // Payment status texts
  static const String statusPaid = 'paid';
  static const String statusPending = 'pending';
  static const String statusOverdue = 'overdue';
  static const String statusCancelled = 'cancelled';

  // Grace period for payments (in days)
  static const int gracePeriodDays = 7;

  // Late payment penalties
  static const double latePaymentPenalty = 5.0; // 5 ETB penalty
  static const int penaltyAfterDays = 15; // Penalty after 15 days overdue

  // Notification reminders
  static const List<int> reminderDaysBeforeDue = [
    7,
    3,
    1,
  ]; // Days before due date to send reminders
  static const List<int> reminderDaysAfterDue = [
    1,
    7,
    14,
  ]; // Days after due date to send reminders

  // Payment categories
  static const String categoryMembership = 'membership';
  static const String categoryEvent = 'event';
  static const String categoryDonation = 'donation';
  static const String categoryOther = 'other';

  // Currency
  static const String currency = 'ETB';
  static const String currencySymbol = 'ETB';

  // Receipt settings
  static const String receiptPrefix = 'CHOIR';
  static const int receiptNumberLength = 6;

  // Financial year
  static const int financialYearStartMonth = 1; // January
  static const int financialYearEndMonth = 12; // December

  // Payment report settings
  static const List<String> reportTypes = ['monthly', 'quarterly', 'yearly'];
  static const Map<String, String> reportTypeNames = {
    'monthly': 'Monthly Report',
    'quarterly': 'Quarterly Report',
    'yearly': 'Yearly Report',
  };

  // Payment validation
  static const double minimumPaymentAmount = 1.0;
  static const double maximumPaymentAmount = 10000.0;

  // TeleBirr integration
  static const String telebirrAppId = 'your_telebirr_app_id';
  static const String telebirrMerchantId = 'your_merchant_id';
  static const String telebirrCallbackUrl =
      'https://your-domain.com/telebirr-callback';

  // M-Pesa integration
  static const String mpesaBusinessShortCode = 'your_business_shortcode';
  static const String mpesaPasskey = 'your_passkey';
  static const String mpesaCallbackUrl =
      'https://your-domain.com/mpesa-callback';

  // Helper methods
  static DateTime getNextDueDate(String cycle) {
    final now = DateTime.now();

    switch (cycle) {
      case cycleWeekly:
        final daysUntilNextMonday = (DateTime.monday - now.weekday + 7) % 7;
        return DateTime(now.year, now.month, now.day + daysUntilNextMonday);
      case cycleMonthly:
        return DateTime(now.year, now.month + 1, monthlyDueDay);
      case cycleYearly:
        return DateTime(now.year + 1, yearlyDueMonth, yearlyDueDay);
      default:
        return DateTime(now.year, now.month + 1, monthlyDueDay);
    }
  }

  static bool isPaymentOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(
      dueDate.add(const Duration(days: gracePeriodDays)),
    );
  }

  static double calculateAmountWithPenalty(
    DateTime dueDate,
    double baseAmount,
  ) {
    if (!isPaymentOverdue(dueDate)) {
      return baseAmount;
    }

    final overdueDays = DateTime.now().difference(dueDate).inDays;
    if (overdueDays > penaltyAfterDays) {
      return baseAmount + latePaymentPenalty;
    }

    return baseAmount;
  }

  static String generateReceiptNumber(int sequence) {
    return '$receiptPrefix${sequence.toString().padLeft(receiptNumberLength, '0')}';
  }
}
