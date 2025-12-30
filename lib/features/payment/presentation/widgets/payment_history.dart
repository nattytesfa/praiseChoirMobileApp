import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gal/gal.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/core/widgets/common/empty_state.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';

class PaymentHistory extends StatefulWidget {
  final List<PaymentModel>? payments;
  final void Function(String)? onMarkAsPaid;
  final String title;

  const PaymentHistory({
    super.key,
    this.payments,
    this.onMarkAsPaid,
    this.title = 'Payment History',
  });

  @override
  State<PaymentHistory> createState() => _PaymentHistoryState();
}

class _PaymentHistoryState extends State<PaymentHistory> {
  Map<String, String> _memberNames = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCubit>().loadAllPayments();
      _loadMemberNames();
    });
  }

  Future<void> _loadMemberNames() async {
    try {
      final users = await context.read<AuthRepository>().getAllUsers();
      if (mounted) {
        setState(() {
          _memberNames = {for (var u in users) u.id: u.name};
        });
      }
    } catch (e) {
      // Handle error silently or log it
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Paid'),
              Tab(text: 'Overdue'),
              Tab(text: 'Pending'),
            ],
          ),
        ),
        body: Builder(
          builder: (context) {
            // If payments are provided, render the tab view with filtered lists.
            if (widget.payments != null) {
              return _buildTabBarView(widget.payments!);
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
                  return _buildTabBarView(state.payments);
                }

                return const Center(child: CircularProgressIndicator());
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBarView(List<PaymentModel> allPayments) {
    final paid = allPayments
        .where((p) => p.status == PaymentStatus.paid)
        .toList();
    final overdue = allPayments
        .where((p) => p.status == PaymentStatus.overdue)
        .toList();
    final pending = allPayments
        .where((p) => p.status == PaymentStatus.pending)
        .toList();

    return TabBarView(
      children: [
        _buildList(paid, 'No paid payments found.'),
        _buildList(overdue, 'No overdue payments found.'),
        _buildList(pending, 'No pending payments found.'),
      ],
    );
  }

  Widget _buildList(List<PaymentModel> list, String emptyMessage) {
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.payment,
        title: 'No Payments',
        message: emptyMessage,
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

  Widget _buildPaymentItem(PaymentModel payment) {
    final memberName = _memberNames[payment.memberId] ?? 'Loading...';

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
                        'Member: $memberName',
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
            if (payment.status != PaymentStatus.paid &&
                widget.onMarkAsPaid != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => widget.onMarkAsPaid!(payment.id),
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
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () => _showPaymentProof(
                      context,
                      payment.proofImagePath!,
                      payment.id,
                    ),
                    icon: const Icon(Icons.receipt),
                    label: const Text('View Payment Proof'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                  if (payment.adminNote != null) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: payment.adminNote!,
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showPaymentProof(BuildContext context, String path, String paymentId) {
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
          if (path != 'proof_path') ...[
            TextButton(
              onPressed: () async {
                try {
                  await Gal.putImage(path, album: 'pccp');
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved to gallery in pccp album'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error saving image: $e')),
                    );
                  }
                }
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Proof'),
                    content: const Text(
                      'Are you sure you want to delete this payment proof?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<PaymentCubit>().removePaymentProof(
                    paymentId,
                  );
                  if (context.mounted) {
                    Navigator.pop(context); // Close the proof dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Payment proof deleted')),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
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
