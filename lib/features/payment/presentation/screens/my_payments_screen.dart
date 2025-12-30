import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/core/widgets/common/loading_indicator.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:image_picker/image_picker.dart';
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

  Future<void> _markAsPaid(PaymentModel payment, double additionalFee) async {
    final picker = ImagePicker();

    // Show dialog to choose source
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Proof'),
        content: const Text(
          'Please upload a screenshot or photo of your payment receipt.',
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Processing payment...')));

    final authState = context.read<AuthCubit>().state;
    final memberId = authState is AuthAuthenticated ? authState.user.id : null;

    await context.read<PaymentCubit>().markPaymentAsPaid(
      payment.id,
      additionalFee: additionalFee,
      memberId: memberId,
      proofImagePath: image.path,
    );
  }

  Future<void> _editPaymentProof(String paymentId) async {
    final picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Payment Proof'),
        content: const Text('Choose image source'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Camera'),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(source: source);

    if (image == null) return;
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Updating proof...')));

    final authState = context.read<AuthCubit>().state;
    final memberId = authState is AuthAuthenticated ? authState.user.id : null;

    await context.read<PaymentCubit>().updatePaymentProof(
      paymentId,
      image.path,
      memberId: memberId,
    );
  }

  void _showPaymentProof(String path, String paymentId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Proof'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (path != 'proof_path')
              Flexible(child: Image.file(File(path), fit: BoxFit.contain))
            else ...[
              const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'This is a placeholder for the payment proof image.',
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editPaymentProof(paymentId);
            },
            child: const Text('Edit'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.overdue:
        return 'Overdue';
    }
  }

  Color _getStatusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return Colors.green;
      case PaymentStatus.pending:
        return Colors.orange;
      case PaymentStatus.overdue:
        return Colors.red;
    }
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
                  onPay: (payment, fee) => _markAsPaid(payment, fee),
                  onViewProof: _showPaymentProof,
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
    final additionalFee = payment.status == PaymentStatus.overdue ? 5.0 : 0.0;
    final totalDue = payment.amount + additionalFee;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            payment.status,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getStatusColor(payment.status),
                          ),
                        ),

                        child: Text(
                          _getStatusText(payment.status),
                          style: TextStyle(
                            color: _getStatusColor(payment.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Due: ${_formatDate(payment.dueDate)}',
                        style: AppTextStyles.caption,
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

            if (payment.status != PaymentStatus.paid) ...[
              Text(
                payment.status == PaymentStatus.overdue
                    ? 'Includes ETB 5.00 overdue fee. Total: ETB ${totalDue.toStringAsFixed(2)}'
                    : 'Total: ETB ${totalDue.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => _markAsPaid(payment, additionalFee),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: payment.status == PaymentStatus.overdue
                        ? Colors.red
                        : AppColors.primary,
                  ),
                  child: Text(
                    'Pay ETB ${totalDue.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
            if (payment.proofImagePath != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () =>
                      _showPaymentProof(payment.proofImagePath!, payment.id),
                  icon: const Icon(Icons.receipt),
                  label: const Text('View Proof'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime date) {
  return '${date.day}/${date.month}/${date.year}';
}
