import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
                  isDenied ? "Access Denied" : "Pending Approval",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isDenied
                      ? "Reason: ${user?.adminMessage}. Please contact leaders for details."
                      : "A leader needs to verify your account before you can access choir tools.",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().logout(context),
                  child: const Text("Return to login"),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      context.read<AuthCubit>().refreshUserStatus(),
                  icon: const Icon(Icons.refresh),
                  label: const Text("Check if Approved"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
