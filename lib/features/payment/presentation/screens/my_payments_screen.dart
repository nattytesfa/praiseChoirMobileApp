import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import '../widgets/payment_status_card.dart';
import '../widgets/payment_history_list.dart';
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

            return Column(
              children: [
                PaymentStatusCard(
                  payment: currentPayment,
                  onMarkAsPaid: () => _markAsPaid(currentPayment.id),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Payment History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: PaymentHistory(
                    payments: payments,
                    onMarkAsPaid: _markAsPaid,
                  ),
                ),
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
}
