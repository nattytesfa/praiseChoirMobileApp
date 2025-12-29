import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';
import 'package:praise_choir_app/features/payment/data/models/payment_report_model.dart';
import 'package:praise_choir_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:praise_choir_app/features/payment/presentation/screens/payment_dashboard.dart';
import 'package:praise_choir_app/features/payment/presentation/screens/payment_reports_screen.dart';
import 'package:praise_choir_app/features/payment/presentation/widgets/payment_history_list.dart';

class PaymentRoutes {
  static const String dashboard = '/payment/dashboard';
  static const String history = '/payment/history';
  static const String report = '/payment/report';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const PaymentDashboard(),
          settings: settings,
        );

      case history:
        return MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) {
              final authState = context.read<AuthCubit>().state;
              final userId = (authState is AuthAuthenticated)
                  ? authState.user.id
                  : '';
              return PaymentCubit()..loadMyPayments(userId);
            },
            child: const PaymentHistory(),
          ),
          settings: settings,
        );

      case report:
        final PaymentReportModel report =
            settings.arguments as PaymentReportModel;
        return MaterialPageRoute(
          builder: (_) => PaymentReportScreen(report: report),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No payment route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      dashboard: (context) => const PaymentDashboard(),
      history: (context) => const PaymentHistory(),
    };
  }


  static void navigateToDashboard(BuildContext context) {
    Navigator.pushNamed(context, dashboard);
  }

  static void navigateToHistory(BuildContext context) {
    Navigator.pushNamed(context, history);
  }

  static void navigateToReport(
    BuildContext context,
    PaymentReportModel report,
  ) {
    Navigator.pushNamed(context, report as String, arguments: report);
  }

  // Modal routes
  static Future<T?> showPaymentProof<T>({
    required BuildContext context,
    required String imagePath,
  }) {
    return showDialog<T>(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Payment Proof',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Image.asset(imagePath), // Would be from network or file
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
