import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:praise_choir_app/features/auth/presentation/cubit/auth_state.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final user = (state is AuthAuthenticated) ? state.user : null;
          final isDenied = user?.approvalStatus == 'denied';

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Icon(
                    isDenied ? Icons.block : Icons.hourglass_top,
                    size: 80,
                    color: isDenied ? Colors.red : Colors.orange,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  isDenied ? "accessDenied".tr() : "pendingApproval".tr(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isDenied
                      ? "accessDeniedReason".tr(
                          namedArgs: {'reason': user?.adminMessage ?? ''},
                        )
                      : "pendingApprovalMsg".tr(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () => context.read<AuthCubit>().logout(context),
                  child: Text("returnToLogin".tr()),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () =>
                      context.read<AuthCubit>().refreshUserStatus(),
                  icon: const Icon(Icons.refresh),
                  label: Text("checkIfApproved".tr()),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
