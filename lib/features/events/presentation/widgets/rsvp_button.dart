import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class RsvpButton extends StatelessWidget {
  final bool currentStatus;
  final Function(bool) onStatusChanged;

  const RsvpButton({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Will you attend?', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text(
                'Attending',
                style: TextStyle(color: Colors.white),
              ),
              selected: currentStatus,
              onSelected: (_) => onStatusChanged(true),
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[200],
            ),
            ChoiceChip(
              label: Text(
                'Not Attending',
                style: TextStyle(
                  color: !currentStatus ? Colors.white : AppColors.textPrimary,
                ),
              ),
              selected: !currentStatus,
              onSelected: (_) => onStatusChanged(false),
              selectedColor: Colors.red,
              backgroundColor: Colors.grey[200],
            ),
          ],
        ),
      ],
    );
  }
}
