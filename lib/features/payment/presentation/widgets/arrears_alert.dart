import 'package:flutter/material.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';

class ArrearsAlert extends StatelessWidget {
  final int overdueCount;
  final VoidCallback onViewOverdue;

  const ArrearsAlert({
    super.key,
    required this.overdueCount,
    required this.onViewOverdue,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.red, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Arrears Alert',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$overdueCount member${overdueCount == 1 ? '' : 's'} have overdue payments',
                    style: AppTextStyles.caption.copyWith(color: Colors.red),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onViewOverdue,
              child: const Text('View', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
