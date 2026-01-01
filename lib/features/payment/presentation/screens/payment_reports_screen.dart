import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';

class PaymentReportScreen extends StatelessWidget {
  final PaymentReportModel report;

  const PaymentReportScreen({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('paymentReport'.tr()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.share)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.download)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Report Header
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'paymentReportTitle'.tr(
                        args: ['${report.month.month}/${report.month.year}'],
                      ),
                      style: AppTextStyles.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'generatedOn'.tr(args: [_formatDate(report.generatedAt)]),
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildSummaryCard(
                  'totalMembers'.tr(),
                  report.totalMembers.toString(),
                  Icons.people,
                  AppColors.primary,
                ),
                _buildSummaryCard(
                  'paid'.tr(),
                  '${report.paidCount} (${report.collectionRate.toStringAsFixed(1)}%)',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildSummaryCard(
                  'pending'.tr(),
                  report.pendingCount.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  'overdue'.tr(),
                  report.overdueCount.toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Financial Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'financialSummary'.tr(),
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildFinancialItem(
                      'totalExpected'.tr(),
                      'etbAmount'.tr(
                        args: [(report.totalMembers * 10.0).toStringAsFixed(2)],
                      ),
                    ),
                    _buildFinancialItem(
                      'totalCollected'.tr(),
                      'etbAmount'.tr(
                        args: [report.totalAmount.toStringAsFixed(2)],
                      ),
                    ),
                    _buildFinancialItem(
                      'collectionRate'.tr(),
                      '${report.collectionRate.toStringAsFixed(1)}%',
                    ),
                    _buildFinancialItem(
                      'outstanding'.tr(),
                      'etbAmount'.tr(
                        args: [
                          ((report.totalMembers * 10.0) - report.totalAmount)
                              .toStringAsFixed(2),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Collection Chart (Simplified)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'collectionDistribution'.tr(),
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _buildCollectionChart(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionChart() {
    final paidPercentage = report.paidCount / report.totalMembers;
    final pendingPercentage = report.pendingCount / report.totalMembers;
    final overduePercentage = report.overdueCount / report.totalMembers;

    return Column(
      children: [
        SizedBox(
          height: 20,
          child: Row(
            children: [
              Expanded(
                flex: (paidPercentage * 100).round(),
                child: Container(
                  color: Colors.green,
                  child: Center(
                    child: Text(
                      'paid'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (pendingPercentage * 100).round(),
                child: Container(
                  color: Colors.orange,
                  child: Center(
                    child: Text(
                      'pending'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: (overduePercentage * 100).round(),
                child: Container(
                  color: Colors.red,
                  child: Center(
                    child: Text(
                      'overdue'.tr(),
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildChartLegend('paid'.tr(), Colors.green, report.paidCount),
            _buildChartLegend(
              'pending'.tr(),
              Colors.orange,
              report.pendingCount,
            ),
            _buildChartLegend('overdue'.tr(), Colors.red, report.overdueCount),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color, int count) {
    return Row(
      children: [
        Container(width: 12, height: 12, color: color),
        const SizedBox(width: 4),
        Text('$label ($count)', style: AppTextStyles.caption),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
