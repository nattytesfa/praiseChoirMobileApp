import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';

class PaymentHistory extends StatelessWidget {
  final List<PaymentModel>? payments;
  final void Function(String)? onMarkAsPaid;

  const PaymentHistory({super.key, this.payments, this.onMarkAsPaid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Builder(
        builder: (context) {
          // If payments are provided, render a simple list (used when embedded).
          if (payments != null) {
            final list = payments!;
            if (list.isEmpty) {
              return const EmptyState(
                icon: Icons.payment,
                title: 'No Payments',
                message: 'No payment history available.',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final payment = list[index];
                return _buildPaymentItem(payment);
              },
            );
          }

          // Otherwise, fall back to listening to PaymentCubit (full-screen route).
          return BlocBuilder<PaymentCubit, PaymentState>(
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
                final list = state.payments;

                if (list.isEmpty) {
                  return const EmptyState(
                    icon: Icons.payment,
                    title: 'No Payments',
                    message: 'No payment history available.',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final payment = list[index];
                    return _buildPaymentItem(payment);
                  },
                );
              }

              return const Center(child: CircularProgressIndicator());
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentItem(PaymentModel payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(payment.status),
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
            const SizedBox(height: 8),
            if (payment.status != PaymentStatus.paid && onMarkAsPaid != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => onMarkAsPaid!(payment.id),
                  child: const Text('Mark as Paid'),
                ),
              ),
            if (payment.paidDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Paid: ${_formatDate(payment.paidDate!)}',
                style: AppTextStyles.caption,
              ),
            ],
            if (payment.proofImagePath != null) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                },
                icon: const Icon(Icons.receipt),
                label: const Text('View Payment Proof'),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return const Icon(Icons.check_circle, color: Colors.green);
      case PaymentStatus.overdue:
        return const Icon(Icons.warning, color: Colors.red);
      case PaymentStatus.pending:
        return const Icon(Icons.pending, color: Colors.orange);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
