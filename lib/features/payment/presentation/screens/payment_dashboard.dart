import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/features/payment/presentation/widgets/arrears_alert.dart';
import 'package:praise_choir_app/features/payment/presentation/widgets/payment_summary.dart';

class PaymentDashboard extends StatefulWidget {
  const PaymentDashboard({super.key});

  @override
  State<PaymentDashboard> createState() => _PaymentDashboardState();
}

class _PaymentDashboardState extends State<PaymentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCubit>().loadAllPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentCubit>().loadAllPayments();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<PaymentCubit>().loadAllPayments(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentLoaded) {
            final summary = state.summary;
            final payments = state.payments;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Overdue Alerts
                  if (summary != null && (summary['overdueCount'] as int) > 0)
                    ArrearsAlert(
                      overdueCount: summary['overdueCount'] as int,
                      onViewOverdue: () {
                        context.read<PaymentCubit>().getOverduePayments();
                      },
                    ),

                  if (summary != null && (summary['overdueCount'] as int) > 0)
                    const SizedBox(height: 16),

                  // Payment Summary
                  if (summary != null) PaymentSummary(summary: summary),
                  if (summary != null) const SizedBox(height: 16),

                  // Recent Payments
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Recent Payments',
                                style: AppTextStyles.titleMedium,
                              ),
                              const Spacer(),
                              Text(
                                '${payments.length} total',
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...payments
                              .take(5)
                              .map((payment) => _buildPaymentItem(payment)),
                          if (payments.length > 5) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton(
                                onPressed: () {
                                },
                                child: const Text('View All Payments'),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPaymentItem(PaymentModel payment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            payment.status == PaymentStatus.paid
                ? Icons.check_circle
                : payment.isOverdue
                ? Icons.warning
                : Icons.pending,
            color: payment.status == PaymentStatus.paid
                ? Colors.green
                : payment.isOverdue
                ? Colors.red
                : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Member: ${payment.memberId}', 
                  style: AppTextStyles.bodyMedium,
                ),
                Text(
                  'Due: ${_formatDate(payment.dueDate)}',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            'ETB ${payment.amount}',
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
