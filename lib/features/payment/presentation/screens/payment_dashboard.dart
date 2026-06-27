import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/features/payment/presentation/widgets/payment_adjustment_card.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_settings.dart';
import 'package:praise_choir_app/features/payment/payment_routes.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';

class PaymentDashboard extends StatefulWidget {
  const PaymentDashboard({super.key});

  @override
  State<PaymentDashboard> createState() => _PaymentDashboardState();
}

class _PaymentDashboardState extends State<PaymentDashboard> {
  PaymentSettings? _settings;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final cubit = context.read<PaymentCubit>();
    cubit.loadAllPayments();
    final settings = await cubit.paymentRepository.getSettings();
    if (mounted) {
      setState(() => _settings = settings);
    }
  }

  Future<void> _onManualGenerate() async {
    final authRepo = context.read<AuthRepository>();
    final cubit = context.read<PaymentCubit>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('generateMonthlyPayments'.tr()),
        content: Text('generatePaymentsConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('generate'.tr()),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final allUsers = await authRepo.getAllUsers();
    if (!mounted) return;

    final activeMemberIds = allUsers
        .where((u) => u.isActive)
        .map((u) => u.id)
        .toList();

    cubit.manualGenerateWithSettings(activeMemberIds);
    messenger.showSnackBar(SnackBar(content: Text('generatingPayments'.tr())));
  }

  Future<void> _onSettingsSaved(PaymentSettings newSettings) async {
    await context.read<PaymentCubit>().updateSettings(newSettings);
    if (!mounted) return;
    setState(() => _settings = newSettings);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('paymentDashboard'.tr()),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
        builder: (context, state) {
          if (state is PaymentLoading && _settings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PaymentError && _settings == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message, style: AppTextStyles.bodyMedium),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          final summary = (state is PaymentLoaded) ? state.summary : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_settings != null)
                  PaymentAdjustmentCard(
                    settings: _settings!,
                    onSettingsSaved: _onSettingsSaved,
                    onManualGenerate: _onManualGenerate,
                  ),
                const SizedBox(height: 12),
                _buildNavigationCard(
                  context,
                  title: 'paymentHistory'.tr(),
                  subtitle: 'viewPaymentRecords'.tr(),
                  icon: Icons.history,
                  color: Colors.blue,
                  onTap: () => Navigator.pushNamed(
                    context,
                    PaymentRoutes.adminHistory,
                  ),
                ),
                const SizedBox(height: 12),
                _buildNavigationCard(
                  context,
                  title: 'paymentReports'.tr(),
                  subtitle: 'viewFinancialAnalytics'.tr(),
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                  onTap: () {
                    if (summary != null) {
                      final report = PaymentReportModel(
                        id: 'report_${DateTime.now().millisecondsSinceEpoch}',
                        month: DateTime.now(),
                        totalMembers: summary['totalMembers'] as int,
                        paidCount: summary['paidCount'] as int,
                        pendingCount: summary['pendingCount'] as int,
                        overdueCount: summary['overdueCount'] as int,
                        collectionRate: (summary['collectionRate'] as num)
                            .toDouble(),
                        totalAmount: (summary['totalAmount'] as num)
                            .toDouble(),
                        generatedAt: DateTime.now(),
                      );
                      Navigator.pushNamed(
                        context,
                        PaymentRoutes.report,
                        arguments: report,
                      );
                    }
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavigationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
