import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/core/theme/app_colors.dart';
import 'package:praise_choir_app/core/theme/app_text_styles.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_state.dart';
import 'package:praise_choir_app/features/payment/presentation/widgets/payment_summary.dart';

class FinancialOverview extends StatefulWidget {
  const FinancialOverview({super.key});

  @override
  State<FinancialOverview> createState() => _FinancialOverviewState();
}

class _FinancialOverviewState extends State<FinancialOverview> {
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentCubit>().loadPaymentSummary(_selectedMonth);
    });
  }

  void _selectMonth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null && picked != _selectedMonth) {
      if (!mounted) return;
      setState(() {
        _selectedMonth = picked;
      });
      context.read<PaymentCubit>().loadPaymentSummary(_selectedMonth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Overview'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _selectMonth,
            icon: const Icon(Icons.calendar_today),
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
                    onPressed: () => context
                        .read<PaymentCubit>()
                        .loadPaymentSummary(_selectedMonth),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PaymentLoaded && state.summary != null) {
            final summary = state.summary!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month Selector
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        '${_selectedMonth.month}/${_selectedMonth.year}',
                        style: AppTextStyles.titleMedium,
                      ),
                      trailing: const Icon(Icons.arrow_drop_down),
                      onTap: _selectMonth,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Summary
                  PaymentSummary(summary: summary),
                  const SizedBox(height: 16),

                  // Collection Progress
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Collection Progress',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (summary['collectionRate'] as double) / 100,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              summary['collectionRate'] as double >= 80
                                  ? Colors.green
                                  : summary['collectionRate'] as double >= 50
                                  ? Colors.orange
                                  : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${summary['collectionRate'].toStringAsFixed(1)}% Collected',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: AppTextStyles.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<PaymentCubit>()
                                      .getOverduePayments();
                                },
                                icon: const Icon(Icons.warning),
                                label: const Text('View Overdue'),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                },
                                icon: const Icon(Icons.assignment),
                                label: const Text('Generate Report'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
