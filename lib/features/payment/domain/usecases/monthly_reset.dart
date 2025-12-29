import 'package:praise_choir_app/core/constants/app_constants.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';

class MonthlyReset {
  final PaymentRepository paymentRepository;

  MonthlyReset(this.paymentRepository);

  Future<void> call(List<String> memberIds) async {
    // Create payments for the next month
    final nextMonth = DateTime.now().add(const Duration(days: 30));
    final dueDate = DateTime(
      nextMonth.year,
      nextMonth.month,
      AppConstants.paymentDueDay,
    );

    await paymentRepository.createMonthlyPayments(memberIds, dueDate);
  }

  Future<void> resetOverduePayments() async {
    final allPayments = await paymentRepository.getAllPayments();
    final currentDate = DateTime.now();

    // Mark payments older than 2 months as permanently overdue
    for (final payment in allPayments) {
      if (payment.isOverdue &&
          payment.dueDate.isBefore(
            DateTime(currentDate.year, currentDate.month - 2),
          )) {
        // You might want to add a new status like 'permanently_overdue'
        // or handle this differently based on your business logic
      }
    }
  }
}
