import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import '../widgets/payment_status_card.dart';
import '../cubit/payment_cubit.dart';

class MyPaymentsScreen extends StatefulWidget {
  const MyPaymentsScreen({super.key});

  @override
  State<MyPaymentsScreen> createState() => _MyPaymentsScreenState();
}

class _MyPaymentsScreenState extends State<MyPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadMyPayments();
  }

  void _loadMyPayments() {
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<PaymentCubit>().loadMyPayments(authState.user.id);
    }
  }

  void _markAsPaid(String paymentId) {
    // This would open camera/gallery to capture proof
    // For now, we'll simulate with a placeholder
    context.read<PaymentCubit>().markPaymentAsPaid(paymentId, 'proof_path');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Payments')),
      body: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state is PaymentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is PaymentLoading) {
            return const LoadingIndicator();
          } else if (state is PaymentError) {
            return Center(child: Text(state.message));
          } else if (state is PaymentLoaded) {
            final payments = state.payments;

            if (payments.isEmpty) {
              return const EmptyState(
                message: 'No payment records found',
                icon: Icons.payment,
                title: '',
              );
            }

            // Get current month payment
            final currentMonth = DateTime(
              DateTime.now().year,
              DateTime.now().month,
            );
            final currentPayment = payments.firstWhere(
              (payment) =>
                  payment.dueDate.year == currentMonth.year &&
                  payment.dueDate.month == currentMonth.month,
              orElse: () => payments.first,
            );

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                PaymentStatusCard(
                  payment: currentPayment,
                  onMarkAsPaid: () => _markAsPaid(currentPayment.id),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Payment History',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...payments.map((payment) => _buildPaymentItem(payment)),
              ],
            );
          }
          return const EmptyState(
            message: 'No payment data available',
            icon: Icons.payment,
            title: '',
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
                        'Due: ${_formatDate(payment.dueDate)}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (payment.paidDate != null)
                        Text(
                          'Paid: ${_formatDate(payment.paidDate!)}',
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
