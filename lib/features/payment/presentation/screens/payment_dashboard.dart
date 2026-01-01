import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/auth/data/auth_repository.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/features/payment/payment_routes.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';

class PaymentDashboard extends StatefulWidget {
  const PaymentDashboard({super.key});

  @override
  State<PaymentDashboard> createState() => _PaymentDashboardState();
}

class _PaymentDashboardState extends State<PaymentDashboard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCubit>().loadAllPayments();
    });
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
            onPressed: () {
              context.read<PaymentCubit>().loadAllPayments();
            },
            icon: const Icon(Icons.refresh),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete_pending') {
                _showDeleteConfirmation(context, includePaid: false);
              } else if (value == 'delete_all') {
                _showDeleteConfirmation(context, includePaid: true);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'delete_pending',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_outline, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text('deletePendingPayments'.tr()),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_forever, color: Colors.red),
                      const SizedBox(width: 8),
                      Text('deleteAllPayments'.tr()),
                    ],
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: BlocBuilder<PaymentCubit, PaymentState>(
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
                    child: Text('retry'.tr()),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentLoaded) {
            final summary = state.summary;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),
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
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final paymentCubit = context.read<PaymentCubit>();
          final authRepo = context.read<AuthRepository>();

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
          if (!context.mounted) return;

          final users = await authRepo.getAllUsers();

          if (!context.mounted) return;

          final memberIds = users.map((u) => u.id).toList();
          paymentCubit.createMonthlyPayments(memberIds);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('generatingPayments'.tr())));
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('generatePayments'.tr()),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context, {
    required bool includePaid,
  }) async {
    final title = includePaid
        ? 'deleteAllPayments'.tr()
        : 'deletePendingPayments'.tr();
    final content = includePaid
        ? 'deleteAllPaymentsConfirm'.tr()
        : 'deletePendingPaymentsConfirm'.tr();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.read<PaymentCubit>().deleteMonthlyPayments(
        includePaid: includePaid,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            includePaid
                ? 'deletingAllPayments'.tr()
                : 'deletingPendingPayments'.tr(),
          ),
        ),
      );
    }
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
