import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_settings.dart';

class PaymentAdjustmentCard extends StatelessWidget {
  final PaymentSettings settings;
  final ValueChanged<PaymentSettings> onSettingsSaved;
  final VoidCallback onManualGenerate;

  const PaymentAdjustmentCard({
    super.key,
    required this.settings,
    required this.onSettingsSaved,
    required this.onManualGenerate,
  });

  @override
  Widget build(BuildContext context) {
    final generatedText = settings.hasGeneratedThisMonth
        ? 'Generated: ${settings.lastGenerated!.day}/${settings.lastGenerated!.month}'
        : 'Not yet generated';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.tune, color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Settings',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        generatedText,
                        style: TextStyle(
                          fontSize: 13,
                          color: settings.hasGeneratedThisMonth
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _infoRow(context, 'Amount', 'ETB ${settings.paymentAmount}'),
            _infoRow(context, 'Due day', '${settings.dueDay}th of month'),
            _infoRow(context, 'Late fee', 'ETB ${settings.lateFee}'),
            _infoRow(
              context,
              'Auto-generate',
              settings.autoGenerate ? 'On' : 'Off',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditDialog(context),
                    icon: const Icon(Icons.edit, size: 18),
                    label: Text('Edit Settings'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onManualGenerate,
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text('Generate Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditDialog(BuildContext context) async {
    final amountCtrl = TextEditingController(
      text: settings.paymentAmount.toString(),
    );
    final dueDayCtrl = TextEditingController(text: settings.dueDay.toString());
    final lateFeeCtrl = TextEditingController(
      text: settings.lateFee.toString(),
    );
    bool autoGen = settings.autoGenerate;

    final result = await showDialog<PaymentSettings>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Edit Payment Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Payment Amount (ETB)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dueDayCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Due Day of Month (1-28)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: lateFeeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Late Fee (ETB)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Auto-generate monthly'),
                  value: autoGen,
                  onChanged: (v) => setDialogState(() => autoGen = v),
                ),
                if (autoGen && settings.lastGenerated != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Last generated: ${settings.lastGenerated!.day}/${settings.lastGenerated!.month}/${settings.lastGenerated!.year}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('cancel'.tr()),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  ctx,
                  PaymentSettings(
                    paymentAmount:
                        double.tryParse(amountCtrl.text) ??
                        settings.paymentAmount,
                    dueDay: int.tryParse(dueDayCtrl.text) ?? settings.dueDay,
                    lateFee:
                        double.tryParse(lateFeeCtrl.text) ?? settings.lateFee,
                    autoGenerate: autoGen,
                    lastGenerated: settings.lastGenerated,
                  ),
                );
              },
              child: Text('save'.tr()),
            ),
          ],
        ),
      ),
    );

    if (result != null && context.mounted) {
      onSettingsSaved(result);
    }
  }
}
