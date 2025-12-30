import 'package:flutter/material.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_model.dart';

class PaymentStatusCard extends StatelessWidget {
  final PaymentModel payment;
  final void Function(PaymentModel payment, double additionalFee) onPay;
  final void Function(String path, String paymentId)? onViewProof;

  const PaymentStatusCard({
    super.key,
    required this.payment,
    required this.onPay,
    this.onViewProof,
  });

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

  Widget _buildPaymentButton(double additionalFee, double totalDue) {
    if (payment.status == PaymentStatus.paid) {
      return const Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('Payment Completed', style: TextStyle(color: Colors.green)),
        ],
      );
    } else {
      return ElevatedButton(
        onPressed: () => onPay(payment, additionalFee),
        style: ElevatedButton.styleFrom(
          backgroundColor: payment.isOverdue ? Colors.red : Colors.blue,
        ),
        child: Text(
          payment.isOverdue
              ? 'Pay Now (ETB ${totalDue.toStringAsFixed(2)})'
              : 'Pay Now',
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final additionalFee = payment.status == PaymentStatus.overdue ? 5.0 : 0.0;
    final totalDue = payment.amount + additionalFee;
    final String? additionalFeeNote = additionalFee > 0
        ? 'Includes ETB ${additionalFee.toStringAsFixed(2)} overdue fee. Total: ETB ${totalDue.toStringAsFixed(2)}'
        : null;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${payment.dueDate.month}/${payment.dueDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    border: Border.all(color: _getStatusColor(payment.status)),
                  ),
                  child: Text(
                    _getStatusText(payment.status),
                    style: TextStyle(
                      color: _getStatusColor(payment.status),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Amount: ${payment.amount} ETB',
              style: const TextStyle(fontSize: 16),
            ),
            if (additionalFeeNote != null) ...[
              const SizedBox(height: 4),
              Text(
                additionalFeeNote,
                style: const TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Due Date: ${_formatDate(payment.dueDate)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            if (payment.paidDate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Paid Date: ${_formatDate(payment.paidDate!)}',
                style: const TextStyle(fontSize: 14, color: Colors.green),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _buildPaymentButton(additionalFee, totalDue),
                if (payment.proofImagePath != null && onViewProof != null) ...[
                  const SizedBox(width: 12),
                  TextButton.icon(
                    onPressed: () =>
                        onViewProof!(payment.proofImagePath!, payment.id),
                    icon: const Icon(Icons.receipt),
                    label: const Text('View Proof'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
