import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
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
        title: Text('paymentProof'.tr()),
        content: Text('uploadProof'.tr()),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('camera'.tr()),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text('gallery'.tr()),
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
    ).showSnackBar(SnackBar(content: Text('processingPayment'.tr())));

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
        title: Text('updatePaymentProof'.tr()),
        content: Text('chooseImageSource'.tr()),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('camera'.tr()),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text('gallery'.tr()),
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
    ).showSnackBar(SnackBar(content: Text('updatingProof'.tr())));

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
        title: Text('paymentProof'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (path != 'proof_path')
              Flexible(child: Image.file(File(path), fit: BoxFit.contain))
            else ...[
              const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text('proofPlaceholder'.tr(), textAlign: TextAlign.center),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _editPaymentProof(paymentId);
            },
            child: Text('edit'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('close'.tr()),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.paid:
        return 'paid'.tr();
      case PaymentStatus.pending:
        return 'pending'.tr();
      case PaymentStatus.overdue:
        return 'overdue'.tr();
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
      appBar: AppBar(title: Text('myPayments'.tr())),
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
              return EmptyState(
                message: 'noPaymentRecords'.tr(),
                icon: Icons.payment,
                title: '',
              );
            }
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
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Text(
                    'paymentHistory'.tr(),
                    style: AppTextStyles.titleMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...payments.map((payment) => _buildPaymentItem(payment)),
              ],
            );
          }
          return EmptyState(
            message: 'noPaymentData'.tr(),
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
                        '${'dueDate'.tr()}: ${_formatDate(payment.dueDate)}',
                        style: AppTextStyles.caption,
                      ),
                      if (payment.paidDate != null)
                        Text(
                          '${'paid'.tr()}: ${_formatDate(payment.paidDate!)}',
                          style: AppTextStyles.caption,
                        ),
                    ],
                  ),
                ),
                Text(
                  '${'etb'.tr()} ${payment.amount}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            if (payment.status != PaymentStatus.paid) ...[
              Text(
                payment.status == PaymentStatus.overdue
                    ? 'overdueFeeMessage'.tr(
                        args: [totalDue.toStringAsFixed(2)],
                      )
                    : 'totalAmount'.tr(args: [totalDue.toStringAsFixed(2)]),
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _markAsPaid(payment, additionalFee),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: payment.status == PaymentStatus.overdue
                            ? Colors.red
                            : AppColors.primary,
                      ),
                      child: Text(
                        'payAmount'.tr(args: [totalDue.toStringAsFixed(2)]),
                        style: const TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
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
                  label: Text('viewProof'.tr()),
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
