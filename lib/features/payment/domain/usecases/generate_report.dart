import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';
import 'package:praise_choir_app/features/payment/data/payment_repository.dart';

class GenerateReport {
  final PaymentRepository paymentRepository;

  GenerateReport(this.paymentRepository);

  Future<PaymentReportModel> call(DateTime month) async {
    final summary = await paymentRepository.getPaymentSummary(month);

    return PaymentReportModel(
      id: 'report_${month.year}_${month.month}',
      month: month,
      totalMembers: summary['totalMembers'] as int,
      paidCount: summary['paidCount'] as int,
      pendingCount: summary['pendingCount'] as int,
      overdueCount: summary['overdueCount'] as int,
      collectionRate: summary['collectionRate'] as double,
      totalAmount: summary['totalAmount'] as double,
      generatedAt: DateTime.now(),
    );
  }

  Future<List<PaymentReportModel>> generateYearlyReport(int year) async {
    final reports = <PaymentReportModel>[];

    for (int month = 1; month <= 12; month++) {
      final reportDate = DateTime(year, month);
      final report = await call(reportDate);
      reports.add(report);
    }

    return reports;
  }
}
