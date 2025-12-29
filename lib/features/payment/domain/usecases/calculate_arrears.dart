import 'package:praise_choir_app/features/payment/data/payment_repository.dart';

class CalculateArrears {
  final PaymentRepository paymentRepository;

  CalculateArrears(this.paymentRepository);

  Future<double> call(String memberId) async {
    final payments = await paymentRepository.getPaymentsForMember(memberId);
    final overduePayments = payments.where((payment) => payment.isOverdue);

    return overduePayments.fold<double>(
      0.0,
      (double sum, payment) => sum + payment.amount,
    );
  }

  Future<Map<String, double>> calculateAllArrears() async {
    final allPayments = await paymentRepository.getAllPayments();
    final overduePayments = allPayments.where((payment) => payment.isOverdue);

    final arrearsByMember = <String, double>{};

    for (final payment in overduePayments) {
      arrearsByMember.update(
        payment.memberId,
        (value) => value + payment.amount,
        ifAbsent: () => payment.amount,
      );
    }

    return arrearsByMember;
  }

  Future<int> getOverdueMonthsCount(String memberId) async {
    final payments = await paymentRepository.getPaymentsForMember(memberId);
    final overduePayments = payments.where((payment) => payment.isOverdue);
    return overduePayments.length;
  }
}
