import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        title: const Text('Payment Dashboard'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              context.read<PaymentCubit>().loadAllPayments();
            },
            icon: const Icon(Icons.refresh),
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
                    child: const Text('Retry'),
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
                    title: 'Payment History',
                    subtitle: 'View all payment records',
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
                    title: 'Payment Reports',
                    subtitle: 'View financial analytics',
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
              title: const Text('Generate Monthly Payments'),
              content: const Text(
                'This will generate payment records for all active members for the current month. Continue?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Generate'),
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
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Generating payments...')),
          );
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Generate Payments'),
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
